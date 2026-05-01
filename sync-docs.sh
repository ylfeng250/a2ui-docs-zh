#!/usr/bin/env bash
#
# sync-docs.sh - Sync A2UI documentation from the upstream repository
#
# Downloads all .md files and assets from google/A2UI/docs to the local docs/
# and docs-zh/public/assets/ directories.
# Safe to re-run: existing files will be overwritten.
#
set -euo pipefail

REPO_OWNER="google"
REPO_NAME="A2UI"
BRANCH="main"
DOCS_DIR="docs"
ASSETS_DIR="docs-zh/public/assets"
API_BASE="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"
SOURCE_DIR="docs"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p "${DOCS_DIR}" "${ASSETS_DIR}"

echo -e "${GREEN}== Syncing A2UI documentation from ${REPO_OWNER}/${REPO_NAME}:${BRANCH}/${SOURCE_DIR} ==${NC}"
echo ""

# --- Step 1: Sync .md files ---

ALL_FILES=()

collect_md_files() {
  local path="$1"
  local items
  items=$(curl -sfL "${API_BASE}/${path}?ref=${BRANCH}") || return

  while IFS= read -r name && IFS= read -r type; do
    if [ "${type}" = "file" ] && [[ "${name}" == *.md ]]; then
      if [ "${path}" = "${SOURCE_DIR}" ]; then
        ALL_FILES+=("${name}")
      else
        ALL_FILES+=("${path#${SOURCE_DIR}/}/${name}")
      fi
    elif [ "${type}" = "dir" ]; then
      collect_md_files "${path}/${name}"
    fi
  done < <(echo "${items}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data:
    print(item['name'])
    print(item['type'])
")
}

collect_md_files "${SOURCE_DIR}"

if [ ${#ALL_FILES[@]} -eq 0 ]; then
  echo -e "${RED}No .md files found.${NC}"
  exit 1
fi

echo -e "${YELLOW}[1/2] Syncing ${#ALL_FILES[@]} .md files...${NC}"

MD_SUCCESS=0
MD_FAIL=0

for REL_PATH in "${ALL_FILES[@]}"; do
  URL="${RAW_BASE}/${SOURCE_DIR}/${REL_PATH}"
  DEST="${DOCS_DIR}/${REL_PATH}"

  mkdir -p "$(dirname "${DEST}")"

  echo -n "  ${REL_PATH}... "

  if curl -sfL "${URL}" -o "${DEST}"; then
    echo -e "${GREEN}OK${NC}"
    MD_SUCCESS=$((MD_SUCCESS + 1))
  else
    echo -e "${RED}FAILED${NC}"
    MD_FAIL=$((MD_FAIL + 1))
  fi
done

echo ""

# --- Step 2: Sync assets ---

echo -e "${YELLOW}[2/2] Syncing assets...${NC}"

ASSET_SUCCESS=0
ASSET_FAIL=0

ASSET_ITEMS=$(curl -sfL "${API_BASE}/${SOURCE_DIR}/assets?ref=${BRANCH}")

while IFS= read -r name; do
  URL="${RAW_BASE}/${SOURCE_DIR}/assets/${name}"
  DEST="${ASSETS_DIR}/${name}"

  echo -n "  ${name}... "

  if curl -sfL "${URL}" -o "${DEST}"; then
    echo -e "${GREEN}OK${NC}"
    ASSET_SUCCESS=$((ASSET_SUCCESS + 1))
  else
    echo -e "${RED}FAILED${NC}"
    ASSET_FAIL=$((ASSET_FAIL + 1))
  fi
done < <(echo "${ASSET_ITEMS}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for item in data:
    if item['type'] == 'file':
        print(item['name'])
")

echo ""

TOTAL=$((MD_SUCCESS + ASSET_SUCCESS))
TOTAL_FAIL=$((MD_FAIL + ASSET_FAIL))
echo -e "${GREEN}Sync complete: ${MD_SUCCESS} .md files, ${ASSET_SUCCESS} assets (${TOTAL} total), ${TOTAL_FAIL} failed${NC}"

if [ "${TOTAL_FAIL}" -gt 0 ]; then
  echo -e "${RED}Some files failed to download.${NC}"
  exit 1
fi
