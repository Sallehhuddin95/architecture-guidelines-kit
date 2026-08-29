#!/usr/bin/env bash

set -euo pipefail

SOURCE_REPO="${SOURCE_REPO:-Sallehhuddin95/architecture-guidelines-kit}"
BRANCH="${BRANCH:-main}"
TARGET_PATH="${TARGET_PATH:-.}"

copied=()
skipped=()
paths_to_copy=()

section() {
    echo ""
    printf '\033[36m%s\033[0m\n' "$1"
}

prompt_yellow() {
    printf '\033[33m%s\033[0m\n' "$1" >&2
}

warn() {
    printf '\033[31m%s\033[0m\n' "$1" >&2
}

ok() {
    printf '\033[32m%s\033[0m\n' "$1"
}

test_installer_source_root() {
    [ -f "$1/CONSTITUTION.md" ] && [ -d "$1/docs" ] && [ -d "$1/specs" ]
}

read_choice() {
    local prompt="$1" default_key="$2"
    local -a keys labels
    shift 2
    while [ $# -gt 0 ]; do
        keys+=("$1")
        labels+=("$2")
        shift 2
    done

    while true; do
        echo "" >&2
        prompt_yellow "$prompt"
        for ((i = 0; i < ${#keys[@]}; i++)); do
            echo "$((i + 1)). ${labels[$i]}" >&2
        done
        local raw
        read -rp "Choose 1-${#keys[@]} [${default_key}]: " raw
        if [ -z "$raw" ]; then
            raw="$default_key"
        fi
        if [[ "$raw" =~ ^[0-9]+$ ]]; then
            local idx=$((raw - 1))
            if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#keys[@]} ]; then
                echo "${keys[$idx]}"
                return 0
            fi
        fi
        for ((i = 0; i < ${#keys[@]}; i++)); do
            if [ "$raw" = "${keys[$i]}" ]; then
                echo "${keys[$i]}"
                return 0
            fi
        done
        warn "Invalid choice. Try again."
    done
}

read_multi_choice() {
    local prompt="$1"
    local -a keys labels selected
    shift
    while [ $# -gt 0 ]; do
        keys+=("$1")
        labels+=("$2")
        shift 2
    done

    while true; do
        echo "" >&2
        prompt_yellow "$prompt"
        for ((i = 0; i < ${#keys[@]}; i++)); do
            echo "$((i + 1)). ${labels[$i]}" >&2
        done
        local raw
        read -rp "Choose numbers separated by commas (e.g. 1,2): " raw
        selected=()
        local valid=true
        IFS=',' read -ra parts <<< "$raw"
        for part in "${parts[@]}"; do
            part="$(echo "$part" | tr -d ' ')"
            if [[ "$part" =~ ^[0-9]+$ ]]; then
                local idx=$((part - 1))
                if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#keys[@]} ]; then
                    local key="${keys[$idx]}"
                    local found=false
                    for existing in "${selected[@]}"; do
                        if [ "$existing" = "$key" ]; then
                            found=true
                        fi
                    done
                    if [ "$found" = false ]; then
                        selected+=("$key")
                    fi
                else
                    valid=false
                fi
            elif [ -n "$part" ]; then
                valid=false
            fi
        done
        if [ "$valid" = true ] && [ ${#selected[@]} -gt 0 ]; then
            printf '%s\n' "${selected[@]}"
            return 0
        fi
        warn "Invalid choice. Try again."
    done
}

read_yes_no() {
    local prompt="$1" default="$2"
    local token
    if [ "$default" = "true" ]; then
        token="Y/n"
    else
        token="y/N"
    fi

    while true; do
        local raw
        read -rp "${prompt} [${token}]: " raw
        if [ -z "$raw" ]; then
            echo "$default"
            return 0
        fi
        case "$(echo "$raw" | tr '[:upper:]' '[:lower:]')" in
            y|yes) echo "true"; return 0 ;;
            n|no) echo "false"; return 0 ;;
            *) warn "Please answer yes or no." ;;
        esac
    done
}

add_unique_path() {
    local path="$1"
    for existing in "${paths_to_copy[@]}"; do
        if [ "$existing" = "$path" ]; then
            return 0
        fi
    done
    paths_to_copy+=("$path")
}

copy_selection() {
    local relative="$1"
    local source_path="$source_root/$relative"
    local dest_path="$target_path/$relative"

    if [ ! -e "$source_path" ]; then
        echo "Missing source path: $relative" >&2
        exit 1
    fi

    if [ -e "$dest_path" ] && [ "$overwrite_existing" = "false" ]; then
        skipped+=("$relative")
        return 0
    fi

    mkdir -p "$(dirname "$dest_path")"
    cp -R "$source_path" "$dest_path"
    copied+=("$relative")
}

main() {
    target_path="$(cd "$TARGET_PATH" && pwd)"

    section "Architecture Guidelines Kit Installer"
    echo "Target repo: $target_path"

    local install_mode
    install_mode="$(read_choice "What are you setting up?" "1" \
        "new" "New project repo" \
        "existing" "Existing project repo")"

    local project_type
    project_type="$(read_choice "What kind of project is this?" "3" \
        "frontend" "Frontend only" \
        "backend" "Backend only" \
        "mobile" "Mobile only (React Native/Expo)" \
        "fullstack" "Full stack" \
        "generic" "Generic or undecided")"

    local -a frontend_frameworks backend_frameworks
    frontend_frameworks=()
    backend_frameworks=()

    if [ "$project_type" = "frontend" ] || [ "$project_type" = "fullstack" ]; then
        while IFS= read -r line; do
            frontend_frameworks+=("$line")
        done < <(read_multi_choice "Which frontend framework(s)?" \
            "nextjs" "Next.js" \
            "angular" "Angular (standalone)")
    fi

    if [ "$project_type" = "backend" ] || [ "$project_type" = "fullstack" ]; then
        while IFS= read -r line; do
            backend_frameworks+=("$line")
        done < <(read_multi_choice "Which backend framework(s)?" \
            "fastapi" "FastAPI" \
            "django" "Django + DRF" \
            "express" "Express + TypeScript")
    fi

    local setup_level
    setup_level="$(read_choice "How much guidance do you want?" "1" \
        "minimal" "Minimal core guidance" \
        "full" "Full governance setup")"

    local agents_default workflow_default mobile_default adr_default
    if [ "$setup_level" = "full" ]; then
        agents_default="true"
        workflow_default="true"
        adr_default="true"
    else
        agents_default="false"
        workflow_default="false"
        adr_default="false"
    fi
    if [ "$project_type" = "mobile" ]; then
        mobile_default="true"
    else
        mobile_default="false"
    fi

    local include_agents include_workflow include_specs include_mobile include_adr_starters overwrite_existing
    include_agents="$(read_yes_no "Include custom agents (Copilot and opencode)?" "$agents_default")"
    include_workflow="$(read_yes_no "Include workflow guides?" "$workflow_default")"
    include_specs="$(read_yes_no "Include spec templates and spec guides?" "true")"
    include_mobile="$(read_yes_no "Also include mobile (React Native/Expo) guidance?" "$mobile_default")"
    include_adr_starters="$(read_yes_no "Include starter ADR files?" "$adr_default")"
    overwrite_existing="$(read_yes_no "Overwrite existing matching files in the target repo?" "false")"

    local source_root
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if test_installer_source_root "$script_dir"; then
        source_root="$script_dir"
        section "Using local source repo"
        echo "$source_root"
    else
        local temp_root cloned_source_root
        temp_root="$(mktemp -d)"
        trap 'rm -rf "$temp_root"' EXIT
        cloned_source_root="$temp_root/source"
        local repo_clone_url
        repo_clone_url="https://github.com/${SOURCE_REPO}.git"

        section "Cloning source repo"
        echo "$repo_clone_url"
        git clone --depth 1 --branch "$BRANCH" "$repo_clone_url" "$cloned_source_root" >/dev/null

        if ! test_installer_source_root "$cloned_source_root"; then
            echo "Failed to clone a usable source repo from $repo_clone_url" >&2
            exit 1
        fi
        source_root="$cloned_source_root"
    fi

    add_unique_path "CONSTITUTION.md"
    add_unique_path "docs/architecture"
    add_unique_path "docs/shared"
    add_unique_path "docs/adr/README.md"

    if [ "$install_mode" = "new" ]; then
        add_unique_path "NEW_PROJECT_BOOTSTRAP.md"
    else
        add_unique_path "EXISTING_PROJECT_ADOPTION.md"
    fi

    for framework in "${frontend_frameworks[@]}"; do
        case "$framework" in
            nextjs)
                add_unique_path "docs/frontend/FRONTEND_GUIDELINE.md"
                add_unique_path "docs/frontend/naming.md"
                add_unique_path "docs/frontend/testing.md"
                ;;
            angular)
                add_unique_path "docs/frontend/ANGULAR_GUIDELINE.md"
                ;;
        esac
    done

    for framework in "${backend_frameworks[@]}"; do
        case "$framework" in
            fastapi)
                add_unique_path "docs/backend/BACKEND_GUIDELINE.md"
                add_unique_path "docs/backend/api-design.md"
                add_unique_path "docs/backend/database.md"
                add_unique_path "docs/backend/migrations.md"
                add_unique_path "docs/backend/naming.md"
                add_unique_path "docs/backend/security.md"
                add_unique_path "docs/backend/testing.md"
                ;;
            django)
                add_unique_path "docs/backend/DJANGO_GUIDELINE.md"
                ;;
            express)
                add_unique_path "docs/backend/EXPRESS_GUIDELINE.md"
                ;;
        esac
    done

    if [ "$include_mobile" = "true" ]; then
        add_unique_path "docs/mobile"
    fi

    if [ "$include_workflow" = "true" ]; then
        add_unique_path "docs/workflow"
    fi

    if [ "$include_specs" = "true" ]; then
        add_unique_path "specs"
    fi

    if [ "$include_adr_starters" = "true" ]; then
        add_unique_path "docs/adr/0003-use-server-managed-sessions.md"
        add_unique_path "docs/adr/0004-reject-client-tampering-of-protected-fields.md"

        for framework in "${frontend_frameworks[@]}"; do
            case "$framework" in
                nextjs)
                    add_unique_path "docs/adr/0001-adopt-feature-driven-frontend.md"
                    ;;
                angular)
                    add_unique_path "docs/adr/0006-adopt-angular-standalone-frontend.md"
                    ;;
            esac
        done

        for framework in "${backend_frameworks[@]}"; do
            case "$framework" in
                fastapi)
                    add_unique_path "docs/adr/0002-adopt-layered-fastapi-backend.md"
                    ;;
                django)
                    add_unique_path "docs/adr/0007-adopt-django-drf-backend.md"
                    ;;
                express)
                    add_unique_path "docs/adr/0008-adopt-express-typescript-backend.md"
                    ;;
            esac
        done

        if [ "$include_mobile" = "true" ]; then
            add_unique_path "docs/adr/0005-adopt-react-native-expo-for-mobile.md"
        fi
    fi

    if [ "$include_agents" = "true" ]; then
        add_unique_path ".github/agents/README.md"
        add_unique_path ".github/agents/architect.agent.md"
        add_unique_path ".github/agents/reviewer.agent.md"
        add_unique_path ".github/agents/tester.agent.md"
        add_unique_path ".github/agents/refactor.agent.md"
        add_unique_path ".github/agents/documentation.agent.md"

        add_unique_path ".opencode/README.md"
        add_unique_path ".opencode/opencode.json"
        add_unique_path ".opencode/agents/architect.md"
        add_unique_path ".opencode/agents/reviewer.md"
        add_unique_path ".opencode/agents/tester.md"
        add_unique_path ".opencode/agents/refactor.md"
        add_unique_path ".opencode/agents/documentation.md"

        for framework in "${frontend_frameworks[@]}"; do
            case "$framework" in
                nextjs)
                    add_unique_path ".github/agents/expert-nextjs-developer.agent.md"
                    add_unique_path ".opencode/agents/nextjs-architect.md"
                    ;;
                angular)
                    add_unique_path ".github/agents/expert-angular-developer.agent.md"
                    add_unique_path ".opencode/agents/angular-architect.md"
                    ;;
            esac
        done

        for framework in "${backend_frameworks[@]}"; do
            case "$framework" in
                fastapi)
                    add_unique_path ".github/agents/expert-fastapi-developer.agent.md"
                    add_unique_path ".opencode/agents/fastapi-architect.md"
                    ;;
                django)
                    add_unique_path ".github/agents/expert-django-developer.agent.md"
                    add_unique_path ".opencode/agents/django-architect.md"
                    ;;
                express)
                    add_unique_path ".github/agents/expert-express-developer.agent.md"
                    add_unique_path ".opencode/agents/express-architect.md"
                    ;;
            esac
        done

        if [ "$include_mobile" = "true" ]; then
            add_unique_path ".github/agents/expert-react-native-developer.agent.md"
            add_unique_path ".opencode/agents/react-native-architect.md"
        fi
    fi

    section "Copying selected files"
    for relative in "${paths_to_copy[@]}"; do
        copy_selection "$relative"
    done

    section "Install summary"
    ok "Copied: ${#copied[@]}"
    for entry in "${copied[@]}"; do
        echo "  + $entry"
    done

    if [ ${#skipped[@]} -gt 0 ]; then
        prompt_yellow "Skipped existing: ${#skipped[@]}"
        for entry in "${skipped[@]}"; do
            echo "  - $entry" >&2
        done
    fi

    section "Read these first"
    echo "1. CONSTITUTION.md"
    echo "2. docs/architecture/ARCHITECTURE_GUIDELINE.md"
    echo "3. docs/shared/"
    if [ ${#frontend_frameworks[@]} -gt 0 ]; then
        echo "4. the copied frontend framework doc(s) in docs/frontend/"
    fi
    if [ ${#backend_frameworks[@]} -gt 0 ]; then
        echo "4. the copied backend framework doc(s) in docs/backend/"
    fi
    if [ "$include_mobile" = "true" ]; then
        echo "4. docs/mobile/"
    fi

    echo ""
    echo -e "\033[36mTrim or rewrite anything that does not match the target repo before real feature work starts.\033[0m"
}

main "$@"