#!/usr/bin/env python3
"""Global hook: enforce /simplify and /security-review gates.

- /simplify required before /security-review, git commit, and session stop
- /security-review required before git add
"""
import json
import re
import sys

_RE_SIMPLIFY_RUN = re.compile(r'"skill":\s*"simplify"')
_RE_SECURITY_RUN = re.compile(r'"skill":\s*"security-review"')
_RE_GIT_COMMIT = re.compile(r'\bgit\s+commit\b')
_RE_GIT_ADD = re.compile(r'\bgit\s+add\b')
_EDIT_TOOLS = {'Edit', 'Write', 'MultiEdit'}

_PASS = {}
_DENY_PRE = {"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny"}}


def _read_transcript(input_data):
    path = input_data.get('transcript_path')
    if not path:
        return ''
    try:
        with open(path, 'r') as f:
            return f.read()
    except OSError:
        return ''


def _edited_paths(entry):
    """Yield file paths touched by an edit tool call."""
    tool_input = entry.get('toolInput') or entry.get('tool_input') or {}
    tool_name = entry.get('toolName') or entry.get('tool_name') or entry.get('name', '')
    if tool_name not in _EDIT_TOOLS:
        return
    path = tool_input.get('file_path')
    if path:
        yield path
    for edit in tool_input.get('edits', []):
        ep = edit.get('file_path')
        if ep:
            yield ep


def _code_was_changed(transcript):
    """Return True if non-markdown files were edited this session."""
    for line in transcript.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue
        for path in _edited_paths(entry):
            if not (isinstance(path, str) and path.endswith('.md')):
                return True
    return False


def _skill_was_run(transcript, pattern):
    return bool(pattern.search(transcript))


def _check_gate(transcript, skill_pattern, message):
    """Check cheap regex first, then expensive parse."""
    if _skill_was_run(transcript, skill_pattern):
        return _PASS
    if not _code_was_changed(transcript):
        return _PASS
    return message


def main():
    try:
        input_data = json.load(sys.stdin)
    except (json.JSONDecodeError, OSError):
        print('{}')
        sys.exit(0)

    hook_event = input_data.get('hook_event_name', '')

    if hook_event == 'Stop':
        transcript = _read_transcript(input_data)
        result = _check_gate(
            transcript, _RE_SIMPLIFY_RUN,
            {"decision": "block", "reason": "Run /simplify before stopping.",
             "systemMessage": "Code was changed this session. Please run /simplify before stopping."})

    elif hook_event == 'PreToolUse':
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input') or {}

        if tool_name == 'Skill' and tool_input.get('skill') == 'security-review':
            transcript = _read_transcript(input_data)
            result = _check_gate(
                transcript, _RE_SIMPLIFY_RUN,
                {**_DENY_PRE, "systemMessage": "Please run /simplify before /security-review."})

        elif tool_name == 'Bash':
            command = tool_input.get('command', '')

            if _RE_GIT_ADD.search(command):
                transcript = _read_transcript(input_data)
                result = _check_gate(
                    transcript, _RE_SECURITY_RUN,
                    {**_DENY_PRE, "systemMessage": "Please run /security-review on changed files before staging."})

            elif _RE_GIT_COMMIT.search(command):
                transcript = _read_transcript(input_data)
                result = _check_gate(
                    transcript, _RE_SIMPLIFY_RUN,
                    {**_DENY_PRE, "systemMessage": "Please run /simplify on changed files before committing."})

            else:
                result = _PASS
        else:
            result = _PASS

    else:
        result = _PASS

    print(json.dumps(result))
    sys.exit(0)


if __name__ == '__main__':
    main()
