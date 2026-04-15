#!/bin/bash
# Ralph Loop - Autonomous Development Orchestration
#
# Usage: ./loop.sh <plan-file> [options]
#
# Arguments:
#   plan-file             Path to the plan file (required)
#
# Options:
#   --max-iterations N    Stop after N iterations (default: unlimited)
#   --no-push             Disable auto-push after commits
#   --dry-run             Show what would happen without executing
#   --help                Show this help message
#
# Examples:
#   ./loop.sh plans/auth.md                     # Run until plan complete
#   ./loop.sh plans/auth.md --max-iterations 10 # Run max 10 iterations
#   ./loop.sh plans/auth.md --dry-run           # Preview without executing
#   ./loop.sh plans/auth.md --no-push           # Run without auto-pushing

set -euo pipefail

# Configuration
MAX_ITERATIONS=0
AUTO_PUSH=true
DRY_RUN=false
PLAN_FILE=""
PROMPT_FILE="PROMPT.md"

# Show usage
show_usage() {
    head -18 "$0" | tail -16
    exit "${1:-0}"
}

# Parse arguments - first positional arg is plan file
if [[ $# -eq 0 ]]; then
    echo "Error: Plan file is required"
    echo ""
    show_usage 1
fi

# First argument must be plan file (unless --help)
if [[ "$1" == "--help" ]]; then
    show_usage 0
fi

PLAN_FILE="$1"
shift

# Parse remaining options
while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --no-push)
            AUTO_PUSH=false
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_usage 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if plan is complete (all tasks checked)
is_plan_complete() {
    local plan="$1"
    # Count unchecked tasks
    local remaining
    remaining=$(grep -c '^\s*- \[ \]' "$plan" 2>/dev/null || echo "0")
    [[ "$remaining" -eq 0 ]]
}

# Get current branch
get_branch() {
    git branch --show-current
}

# Main loop
main() {
    local plan="$PLAN_FILE"
    local branch
    branch=$(get_branch)
    local iteration=0

    echo "Ralph Loop Starting"
    echo "  Plan: $plan"
    echo "  Branch: $branch"
    echo "  Max iterations: ${MAX_ITERATIONS:-unlimited}"
    echo "  Auto-push: $AUTO_PUSH"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would execute loop with:"
        echo "  cat $PROMPT_FILE | claude -p --dangerously-skip-permissions --model opus"
        echo ""
        echo "Plan contents:"
        cat "$plan"
        exit 0
    fi

    # Verify required files exist
    if [[ ! -f "$PROMPT_FILE" ]]; then
        echo "Error: $PROMPT_FILE not found"
        exit 1
    fi

    if [[ ! -f "$plan" ]]; then
        echo "Error: Plan file not found: $plan"
        exit 1
    fi

    # Trap Ctrl+C for graceful exit
    trap 'echo ""; echo "Loop interrupted at iteration $iteration"; exit 130' INT

    while true; do
        # Check iteration limit
        if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $iteration -ge $MAX_ITERATIONS ]]; then
            echo "Reached max iterations ($MAX_ITERATIONS)"
            break
        fi

        # Check if plan is complete
        if is_plan_complete "$plan"; then
            echo "All tasks complete!"
            break
        fi

        iteration=$((iteration + 1))
        echo "=== Iteration $iteration ==="
        echo ""

        # Run Claude with prompt
        cat "$PROMPT_FILE" | claude -p \
            --dangerously-skip-permissions \
            --model opus \
            --verbose

        # Push if enabled and there are commits to push
        if [[ "$AUTO_PUSH" == true ]]; then
            if git status | grep -q "Your branch is ahead"; then
                echo "Pushing to origin/$branch..."
                git push origin "$branch"
            fi
        fi

        echo ""
        echo "=== Iteration $iteration complete ==="
        echo ""
    done

    echo ""
    echo "Ralph Loop finished after $iteration iterations"
}

main "$@"
