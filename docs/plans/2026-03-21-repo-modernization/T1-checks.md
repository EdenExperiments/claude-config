# T1 Verification Checks — repo-modernization

Run all commands from the repo root (`/home/meden/plan-repo-modernization`).

## AC-1: README lists all 10 commands

```bash
for cmd in plan-feature execute-plan what-next correct-course abandon-feature parallel-session improve tdd-first use-context7 bootstrap; do
  grep -q "$cmd" README.md && echo "AC-1 $cmd: PASS" || echo "AC-1 $cmd: FAIL"
done
```

## AC-2: README documents Agent Teams flag

```bash
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" README.md && echo "AC-2: PASS" || echo "AC-2: FAIL"
```

## AC-3: README documents .claude/rules/ pattern

```bash
grep -q "rules" README.md && echo "AC-3: PASS" || echo "AC-3: FAIL"
```

## AC-4: CLAUDE.md exists with required sections

```bash
[ -f CLAUDE.md ] || { echo "AC-4: FAIL (file missing)"; exit 1; }
for section in "purpose\|Purpose\|what this\|What this" "zone\|Zone\|director" "agent\|Agent" "docs/"; do
  grep -qiE "$section" CLAUDE.md && echo "AC-4 [$section]: PASS" || echo "AC-4 [$section]: FAIL"
done
```

## AC-5: maxTurns in all 4 agent frontmatters

```bash
for agent in orchestrator architect reviewer ux; do
  grep -q "maxTurns" agents/$agent.md && echo "AC-5 $agent: PASS" || echo "AC-5 $agent: FAIL"
done
```

## AC-6: ux.md Read/Write Contract outside code fence

```bash
python3 -c "
import re, sys
content = open('agents/ux.md').read()
blocks = re.findall(r'\x60\x60\x60.*?\x60\x60\x60', content, re.DOTALL)
for block in blocks:
    if 'Read/Write Contract' in block or ('Reads:' in block and 'Writes:' in block):
        print('AC-6: FAIL (Read/Write Contract is inside a code block)')
        sys.exit(1)
print('AC-6: PASS')
"
```

## AC-7: architect and reviewer have tools whitelist (Write yes, Edit/Bash no)

```bash
for agent in architect reviewer; do
  grep -q "^tools:" agents/$agent.md || grep -q "^  tools:" agents/$agent.md || { echo "AC-7 $agent: FAIL (no tools field)"; continue; }
  grep -A5 "^tools:" agents/$agent.md | grep -q "Write" && echo "AC-7 $agent Write: PASS" || echo "AC-7 $agent Write: FAIL"
  grep -A5 "^tools:" agents/$agent.md | grep -q "Edit" && echo "AC-7 $agent Edit-excluded: FAIL" || echo "AC-7 $agent Edit-excluded: PASS"
  grep -A5 "^tools:" agents/$agent.md | grep -q "Bash" && echo "AC-7 $agent Bash-excluded: FAIL" || echo "AC-7 $agent Bash-excluded: PASS"
done
```

## AC-8: All 10 skills in directory format

```bash
for skill in plan-feature execute-plan tdd-first use-context7 parallel-session abandon-feature new-project-bootstrap what-next correct-course improve; do
  [ -f "skills/$skill/SKILL.md" ] && echo "AC-8 $skill: PASS" || echo "AC-8 $skill: FAIL"
done
```

## AC-9: No flat skill .md files at skills/ root

```bash
flat=$(ls skills/*.md 2>/dev/null | wc -l)
[ "$flat" -eq 0 ] && echo "AC-9: PASS" || echo "AC-9: FAIL ($flat flat files remain: $(ls skills/*.md 2>/dev/null))"
```

## AC-10: Symlink resolves to plan-feature/SKILL.md

```bash
ls -la ~/.claude/skills/plan-feature/SKILL.md >/dev/null 2>&1 && echo "AC-10: PASS" || echo "AC-10: FAIL (symlink does not resolve)"
```

## AC-11: install.sh creates ~/.claude/rules

```bash
grep -q "rules" install.sh && echo "AC-11: PASS" || echo "AC-11: FAIL"
```

## AC-12: install.sh conditional Agent Teams reminder with .bashrc/.zshrc mention

```bash
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" install.sh && echo "AC-12a env var: PASS" || echo "AC-12a env var: FAIL"
grep -q "bashrc" install.sh && echo "AC-12b bashrc: PASS" || echo "AC-12b bashrc: FAIL"
grep -q "zshrc" install.sh && echo "AC-12b zshrc: PASS" || echo "AC-12b zshrc: FAIL"
```

## AC-13: settings.local.json includes expanded permissions

```bash
for perm in "git status" "git log" "git diff" "git worktree" "Bash(ls"; do
  grep -q "$perm" .claude/settings.local.json && echo "AC-13 '$perm': PASS" || echo "AC-13 '$perm': FAIL"
done
```

## AC-14: new-project-bootstrap includes docs/sessions/retros/ in mkdir

```bash
grep -q "sessions/retros" skills/new-project-bootstrap/SKILL.md && echo "AC-14: PASS" || echo "AC-14: FAIL"
```

## AC-15: new-project-bootstrap has rules directory step with mkdir and explanation

```bash
grep -q "rules directory" skills/new-project-bootstrap/SKILL.md && echo "AC-15a heading: PASS" || echo "AC-15a heading: FAIL"
grep -q "mkdir -p .claude/rules" skills/new-project-bootstrap/SKILL.md && echo "AC-15b mkdir: PASS" || echo "AC-15b mkdir: FAIL"
```

## AC-16: execute-plan has Prerequisites with Agent Teams flag + fallback

```bash
grep -q "Prerequisites" skills/execute-plan/SKILL.md && echo "AC-16a section: PASS" || echo "AC-16a section: FAIL"
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" skills/execute-plan/SKILL.md && echo "AC-16b env var: PASS" || echo "AC-16b env var: FAIL"
grep -qiE "sequential|single-agent|fallback" skills/execute-plan/SKILL.md && echo "AC-16c fallback: PASS" || echo "AC-16c fallback: FAIL"
```

## AC-16b: No flat-path references to old skill paths

```bash
count=$(grep -rE "skills/[a-z-]+\.md" . --include="*.md" --include="*.sh" \
  | grep -v "docs/plans\|docs/specs\|Binary" | wc -l)
[ "$count" -eq 0 ] && echo "AC-16b: PASS" || echo "AC-16b: FAIL ($count references found)"
grep -rE "skills/[a-z-]+\.md" . --include="*.md" --include="*.sh" \
  | grep -v "docs/plans\|docs/specs\|Binary" || true
```

## AC-17: bmad-comparison.md committed

```bash
git ls-files docs/bmad-comparison.md | grep -q "bmad-comparison" && echo "AC-17: PASS" || echo "AC-17: FAIL"
```

## AC-18: mcp-catalog.md has hytale-rag entry

```bash
grep -q "hytale-rag" docs/mcp-catalog.md && echo "AC-18: PASS" || echo "AC-18: FAIL"
```
