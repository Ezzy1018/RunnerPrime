# Cursor Production Agents 🤖

> **Production-grade AI agents for streamlined software development workflows**

A complete set of specialized agents for Cursor IDE that orchestrate design, development, and QA processes with human oversight and safety controls.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Agent Architecture](#agent-architecture)
- [Setup Instructions](#setup-instructions)
- [Usage Guide](#usage-guide)
- [Example Workflows](#example-workflows)
- [Configuration](#configuration)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## 🎯 Overview

### What This Is

A **four-agent system** that transforms natural language briefs into production-ready code through a controlled, gated workflow:

1. **Master Orchestrator** - Routes tasks and enforces safety
2. **Visual Designer** - Generates design variants with accessibility scores
3. **Builder** - Implements code with tests in sandbox branches
4. **QA Reviewer** - Runs comprehensive checks and gates merges

### Key Features

- ✅ **Human-in-the-Loop**: Requires `APPROVE` for all major actions
- ✅ **Safety First**: Never auto-merges to protected branches
- ✅ **Production Quality**: Accessibility, performance, security checks built-in
- ✅ **Transparent**: Full audit logs with token costs
- ✅ **Flexible**: Works with React, Vue, Swift, Python, and more
- ✅ **Cost Conscious**: Smart model selection per task type

---

## 🚀 Quick Start

### Installation (5 minutes)

1. **Copy agent files to your project:**
   ```bash
   mkdir -p .cursor/agents
   cp agents/*.md .cursor/agents/
   ```

2. **Create agents in Cursor:**
   - Open Cursor Settings → AI → Agents
   - Create 4 new agents with these names:
     - `Master Orchestrator`
     - `Visual Designer`
     - `Builder`
     - `QA Reviewer`

3. **Paste agent prompts:**
   - For each agent, paste the corresponding `.md` file content as the system prompt
   - Set model preferences (see Configuration section)

4. **Attach context (optional but recommended):**
   - Attach key directories like `@src`, `@components`, `@tests`
   - Attach design tokens file if you have one
   - Attach CI/CD config for QA commands

### First Run (2 minutes)

```
You: @Master_Orchestrator Build a responsive button component with hover states

Master: [Returns normalized brief and execution plan]
        Ready to dispatch Task 1 to Visual Designer.
        Reply with APPROVE to proceed.

You: APPROVE

Visual Designer: [Returns 3 design variants]

Master: [Asks you to choose variant]

You: Approve variant B

Master: [Asks to proceed to Builder]

You: APPROVE

Builder: [Implements code, runs tests, creates PR]

Master: [Asks to proceed to QA]

You: APPROVE

QA Reviewer: [Runs checks, returns scorecard]

Master: [Returns final report]
        MERGE RECOMMENDATION: READY
        Reply with APPROVE to merge.

You: APPROVE
```

**Done!** Your feature is ready for merge with full test coverage, accessibility checks, and documentation.

---

## 🏗️ Agent Architecture

### System Diagram

```
┌─────────────────────────────────────────────────┐
│                     Human                        │
│  (Provides briefs, approves checkpoints)        │
└─────────────────┬───────────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────────┐
│          Master Orchestrator                     │
│  • Parses briefs                                │
│  • Creates execution plans                      │
│  • Dispatches to agents                         │
│  • Enforces guardrails                          │
│  • Requires APPROVE at each checkpoint          │
└─────┬─────────────┬─────────────┬───────────────┘
      │             │             │
      ↓             ↓             ↓
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Visual   │  │ Builder  │  │ QA       │
│ Designer │  │          │  │ Reviewer │
├──────────┤  ├──────────┤  ├──────────┤
│ Creates  │  │ Writes   │  │ Runs     │
│ 3 design │  │ code +   │  │ tests +  │
│ variants │  │ tests in │  │ checks   │
│ with a11y│  │ sandbox  │  │ and gates│
│ scores   │  │ branches │  │ merges   │
└──────────┘  └──────────┘  └──────────┘
```

### Agent Responsibilities

| Agent | Inputs | Outputs | Model | Tokens |
|-------|--------|---------|-------|--------|
| **Master Orchestrator** | User brief | Execution plan, audit log | Cheap | ~5k |
| **Visual Designer** | Design requirements | 3 variants + export package | High quality | ~30k |
| **Builder** | Approved design | Code + tests + PR draft | Balanced | ~20k |
| **QA Reviewer** | PR branch | Scorecard + merge decision | Mixed | ~25k |

**Total typical run**: ~80k tokens (~$0.20 with GPT-4)

---

## 🛠️ Setup Instructions

### Step 1: Prerequisites

Before setting up agents, ensure you have:

- ✅ **Cursor IDE** (latest version)
- ✅ **Git repository** initialized
- ✅ **Test suite** (unit tests) configured
- ✅ **Linter** (ESLint, Prettier, etc.) configured
- ✅ **CI/CD** (optional but recommended)

### Step 2: Create Agents in Cursor

#### 2.1 Open Agent Settings
```
Cursor → Settings → AI → Agents → Create New Agent
```

#### 2.2 Configure Master Orchestrator

**Name:** `Master Orchestrator`

**System Prompt:** Paste contents of `master-orchestrator.md`

**Model Settings:**
- Model: `gpt-3.5-turbo` or `claude-3-haiku` (cheaper)
- Temperature: `0.3` (more deterministic)
- Max tokens: `5000`

**Context Attachments:**
- `@.` (root directory)
- `@README.md`
- `@package.json` (or equivalent)

**Enabled:** ✅

#### 2.3 Configure Visual Designer

**Name:** `Visual Designer`

**System Prompt:** Paste contents of `visual-designer.md`

**Model Settings:**
- Model: `gpt-4` or `claude-3-opus` (high quality)
- Temperature: `0.7` (more creative)
- Max tokens: `30000`

**Context Attachments:**
- `@design` (design system folder)
- `@components` (existing components)
- `@styles` or `@tokens` (design tokens)

**Enabled:** ✅

#### 2.4 Configure Builder

**Name:** `Builder`

**System Prompt:** Paste contents of `builder.md`

**Model Settings:**
- Model: `gpt-4` or `claude-3-sonnet` (balanced)
- Temperature: `0.5` (balanced creativity/precision)
- Max tokens: `20000`

**Context Attachments:**
- `@src` (source code)
- `@tests` (test files)
- `@.eslintrc.json` (linter config)
- `@tsconfig.json` (TypeScript config)

**Enabled:** ✅

#### 2.5 Configure QA Reviewer

**Name:** `QA Reviewer`

**System Prompt:** Paste contents of `qa-reviewer.md`

**Model Settings:**
- For checks: `gpt-3.5-turbo` or `claude-3-haiku` (cheaper)
- For fixes: `gpt-4` or `claude-3-sonnet` (balanced)
- Temperature: `0.3` (more deterministic)
- Max tokens: `25000`

**Context Attachments:**
- `@tests` (test files)
- `@.github/workflows` (CI config)
- `@package.json` (test scripts)

**Enabled:** ✅

### Step 3: Configure Your Project

#### 3.1 Update Master Orchestrator Context

Edit placeholders in `master-orchestrator.md`:

```markdown
Replace: [project name]
With: Your actual project name

Replace: [insert test command]
With: npm test (or your test command)

Replace: [insert accessibility audit command]
With: npm run audit-a11y (or your a11y command)
```

#### 3.2 Set Protected Branches

In `master-orchestrator.md`, update protected branches:

```markdown
Protected branches: main, master, production, staging
→ Replace with your actual branch names
```

#### 3.3 Configure Test Commands

Create or update `package.json` with QA commands:

```json
{
  "scripts": {
    "test": "jest",
    "lint": "eslint . --ext .ts,.tsx",
    "audit-a11y": "axe-core src/**/*.tsx",
    "lighthouse": "lighthouse-ci autorun",
    "security-scan": "npm audit",
    "visual-diff": "percy exec -- npm test"
  }
}
```

Adjust based on your tech stack.

### Step 4: Create Audit Log Directory

```bash
mkdir -p agents/audit
touch agents/audit/log.json
echo '[]' > agents/audit/log.json
```

This will store task execution history.

### Step 5: Test the Setup

Run a simple test to verify agents work:

```
@Master_Orchestrator Create a simple Hello World component
```

Expected flow:
1. Master asks for APPROVE
2. Dispatches to Builder (skips Visual Designer for simple tasks)
3. Builder creates component + tests
4. QA runs checks
5. Master returns READY recommendation

If this works, your setup is complete! 🎉

---

## 📖 Usage Guide

### Interacting with Agents

#### Rule 1: Always Start with Master Orchestrator

**✅ Correct:**
```
@Master_Orchestrator Build a search bar with autocomplete
```

**❌ Wrong:**
```
@Builder Add a search bar
```

**Why?** Master Orchestrator enforces safety, creates plans, and maintains audit logs.

#### Rule 2: Use the APPROVE Keyword

Agents wait for explicit approval using the keyword `APPROVE`.

**Example:**
```
Master: Ready to dispatch to Visual Designer.
        Reply with APPROVE to proceed.

You: APPROVE
```

**Other Commands:**
- `APPROVE MERGE` - Approve merge to protected branch
- `OVERRIDE` - Override guardrails (requires justification)
- `PAUSE` - Stop execution
- `ABORT` - Cancel current task

#### Rule 3: Be Specific in Briefs

**✅ Good briefs:**
```
Build a responsive product card with image, title, price, and CTA button.
Target mobile (375px) and desktop (1440px). Use design tokens from /design/tokens.json.
Aim for 90+ Lighthouse performance score.
```

**❌ Vague briefs:**
```
Make a card component
```

**Why?** Specific briefs reduce back-and-forth and lead to better results.

### Common Workflows

#### Workflow 1: Build a New Component

```
1. You: @Master_Orchestrator Build a DatePicker component with 
        keyboard navigation and accessibility features

2. Master: [Returns plan with 3 tasks]
           CHECKPOINT: Task 1 - Visual Designer
           Reply with APPROVE to proceed.

3. You: APPROVE

4. Visual Designer: [Returns 3 variants]
                    Variant A: Calendar Grid
                    Variant B: Dropdown with Calendar
                    Variant C: Input with Popup

5. Master: Which variant to implement?

6. You: Approve variant B

7. Master: CHECKPOINT: Task 2 - Builder
           Reply with APPROVE to proceed.

8. You: APPROVE

9. Builder: [Creates code, tests, PR]
            Status: 42/42 tests passing
            Branch: agent/builder/datepicker-123

10. Master: CHECKPOINT: Task 3 - QA Reviewer
            Reply with APPROVE to proceed.

11. You: APPROVE

12. QA Reviewer: [Runs checks]
                 Scorecard: 95/100
                 Recommendation: READY

13. Master: MERGE RECOMMENDATION: READY
            Reply with APPROVE to merge.

14. You: APPROVE

Done! DatePicker is ready to merge.
```

**Time**: ~10-15 minutes  
**Cost**: ~$0.20 in API calls

#### Workflow 2: Fix a Bug

```
1. You: @Master_Orchestrator Fix the login form validation bug
        where emails with + signs are rejected

2. Master: [Creates plan, skips design since it's a fix]
           CHECKPOINT: Task 1 - Builder
           Reply with APPROVE to proceed.

3. You: APPROVE

4. Builder: [Fixes regex, adds test case]
            New test: Email with + sign should be valid
            Branch: agent/builder/email-validation-fix-456

5. Master: CHECKPOINT: Task 2 - QA Reviewer

6. You: APPROVE

7. QA: Tests: 48/48 passing (1 new)
       Recommendation: READY

8. Master: READY to merge

9. You: APPROVE

Done! Bug fixed with test coverage.
```

**Time**: ~5 minutes  
**Cost**: ~$0.10

#### Workflow 3: Optimize Performance

```
1. You: @Master_Orchestrator Our homepage has LCP of 4.2s. 
        Optimize to get under 2.5s.

2. Master: [Creates analysis plan]
           Task 1: QA Reviewer analyzes current performance
           Task 2: Builder implements optimizations
           Task 3: QA verifies improvements

3. [Follow APPROVE checkpoints]

4. QA (initial): LCP 4.2s
                 Issues: Large images, render-blocking JS

5. Builder: [Optimizes images, lazy loads, code-splits]

6. QA (final): LCP 2.1s ✅
               Recommendation: READY

Done! 50% performance improvement.
```

---

## 💡 Example Workflows

### Example 1: E-commerce Product Card

**Brief:**
```
@Master_Orchestrator Build a product card component for our e-commerce site.

Requirements:
- Show product image, name, price, rating, and "Add to Cart" button
- Responsive: mobile (375px) and desktop (1440px)
- Accessibility: WCAG AA compliant
- Performance: Lazy load images
- Design: Use tokens from /design/tokens.json
```

**What Happens:**

**Task 1 - Visual Designer** (5 min)
- Generates 3 variants (minimal, rich, compact)
- Includes accessibility scores for each
- Recommends variant based on criteria

**Task 2 - Builder** (8 min)
- Implements approved variant
- Adds unit tests (renders, interactions, a11y)
- Creates PR with screenshots

**Task 3 - QA Reviewer** (3 min)
- Runs accessibility audit (score: 94/100)
- Checks performance (LCP: 1.8s)
- Recommendation: READY

**Result:** Production-ready ProductCard component in ~16 minutes

---

### Example 2: Refactor for Performance

**Brief:**
```
@Master_Orchestrator Our dashboard is slow. Optimize for better performance.

Current metrics:
- LCP: 5.2s (target <2.5s)
- FID: 180ms (target <100ms)
- Bundle size: 2.4MB

Focus: Code splitting, lazy loading, reduce bundle size
```

**What Happens:**

**Task 1 - QA Reviewer** (Baseline)
- Runs Lighthouse audit
- Identifies issues: Large bundle, blocking scripts, unoptimized images

**Task 2 - Builder** (Implementation)
- Implements React.lazy() for routes
- Adds dynamic imports for heavy components
- Optimizes images (WebP, responsive sizes)
- Removes unused dependencies

**Task 3 - QA Reviewer** (Validation)
- Re-runs Lighthouse
- New metrics: LCP 2.2s, FID 65ms, Bundle 1.1MB
- Recommendation: READY

**Result:** 58% performance improvement with test coverage

---

### Example 3: Accessibility Remediation

**Brief:**
```
@Master_Orchestrator Our navigation menu fails accessibility audit.

Issues:
- No keyboard navigation
- Missing ARIA labels
- Color contrast 2.8:1 (need 4.5:1)
- Screen reader doesn't announce menu state

Fix all issues to be WCAG AA compliant.
```

**What Happens:**

**Task 1 - QA Reviewer** (Audit)
- Runs axe-core accessibility scanner
- Documents 12 violations (2 critical, 6 serious, 4 moderate)
- Provides detailed reproduction steps

**Task 2 - Builder** (Fix)
- Adds keyboard event handlers (Tab, Enter, Escape, Arrow keys)
- Implements ARIA attributes (role, aria-expanded, aria-label)
- Updates colors for 4.6:1 contrast ratio
- Adds focus management

**Task 3 - QA Reviewer** (Verify)
- Re-runs accessibility audit
- Score: 100/100 (0 violations)
- Manual test: Screen reader navigation works
- Recommendation: READY

**Result:** Fully accessible navigation menu

---

## ⚙️ Configuration

### Model Recommendations

Based on your budget and quality needs:

#### Budget-Conscious Setup (~$0.10 per run)
```
Master Orchestrator: GPT-3.5-turbo
Visual Designer: GPT-4 (only for design tasks)
Builder: GPT-3.5-turbo (code) + GPT-3.5-turbo (docs)
QA Reviewer: GPT-3.5-turbo
```

#### Balanced Setup (~$0.20 per run) ⭐ Recommended
```
Master Orchestrator: Claude 3 Haiku
Visual Designer: Claude 3 Opus or GPT-4
Builder: Claude 3 Sonnet or GPT-4
QA Reviewer: Claude 3 Haiku (checks) + Sonnet (fixes)
```

#### Premium Setup (~$0.40 per run)
```
Master Orchestrator: GPT-4
Visual Designer: GPT-4 or Claude 3 Opus
Builder: GPT-4
QA Reviewer: GPT-4
```

### Tech Stack Configurations

#### React/TypeScript
```json
{
  "framework": "React",
  "language": "TypeScript",
  "test_framework": "Jest + React Testing Library",
  "linter": "ESLint",
  "formatter": "Prettier",
  "a11y_tool": "axe-core",
  "performance_tool": "Lighthouse CI"
}
```

#### Vue.js
```json
{
  "framework": "Vue 3",
  "language": "TypeScript",
  "test_framework": "Vitest + Vue Test Utils",
  "linter": "ESLint",
  "formatter": "Prettier",
  "a11y_tool": "vue-axe",
  "performance_tool": "Lighthouse CI"
}
```

#### iOS/Swift
```json
{
  "platform": "iOS",
  "language": "Swift",
  "framework": "SwiftUI",
  "test_framework": "XCTest",
  "linter": "SwiftLint",
  "a11y_tool": "Accessibility Inspector",
  "performance_tool": "Instruments"
}
```

#### Python/Django
```json
{
  "framework": "Django",
  "language": "Python",
  "test_framework": "pytest",
  "linter": "flake8 + black",
  "formatter": "black",
  "security_tool": "bandit",
  "performance_tool": "django-silk"
}
```

### Customizing Guardrails

Edit thresholds in agent prompts to match your standards:

**Accessibility Threshold** (qa-reviewer.md):
```markdown
Default: ≥85/100 (WCAG AA)
Strict: ≥95/100 (WCAG AAA)
Lenient: ≥70/100 (Basic compliance)
```

**File Change Limit** (builder.md):
```markdown
Default: 25 files
Small teams: 10 files
Large refactors: 50 files (with justification)
```

**Test Failure Threshold** (qa-reviewer.md):
```markdown
Default: <30% failures
Strict: <10% failures
Lenient: <50% failures
```

---

## 🎯 Best Practices

### 1. Start Small

**✅ Do:**
```
@Master_Orchestrator Add a Button component with hover state
```

**❌ Don't:**
```
@Master_Orchestrator Build an entire e-commerce site with auth, 
checkout, inventory management, and analytics
```

**Why?** Start with simple tasks to learn the workflow, then tackle complex projects.

---

### 2. Provide Context

**✅ Do:**
```
@Master_Orchestrator Add dark mode toggle to settings page.

Current setup:
- Using CSS variables for theming
- Design tokens at /styles/tokens.css
- Settings page at /src/pages/Settings.tsx
- Should persist preference to localStorage
```

**❌ Don't:**
```
@Master_Orchestrator Add dark mode
```

---

### 3. Review Agent Output

Don't blindly approve everything. Review:

- ✅ Design variants align with brand
- ✅ Code follows your conventions
- ✅ Tests cover important scenarios
- ✅ No security issues introduced

---

### 4. Iterate on Feedback

If output isn't quite right:

```
@Master_Orchestrator The button padding is too large. 
Reduce from 24px to 16px and re-run QA.
```

Agents can refine based on feedback.

---

### 5. Use Version Control

Always review PR diffs before merging:

```bash
git checkout agent/builder/feature-123
git diff main
# Review changes carefully
```

---

### 6. Monitor Costs

Track token usage in audit logs:

```bash
cat agents/audit/log.json | jq '.[].tokenCost' | awk '{s+=$1} END {print s}'
```

---

### 7. Customize Per Project

Don't use agents as-is. Customize:

- Model selection (budget vs quality)
- Guardrails (strictness level)
- Test commands (your CI/CD setup)
- Design tokens (your design system path)

---

## 🐛 Troubleshooting

### Issue: Agent Doesn't Respond

**Symptoms:** No response after invoking agent

**Solutions:**
1. Check agent is enabled in Settings
2. Verify system prompt is pasted correctly
3. Try invoking with full @AgentName mention
4. Restart Cursor IDE

---

### Issue: "Cannot find command"

**Symptoms:** QA Reviewer says "Missing command: npm run audit-a11y"

**Solutions:**
1. Add missing script to package.json
2. Install required tool (e.g., `npm install -D axe-core`)
3. Or tell QA to skip that specific check

---

### Issue: Builder Changes Too Many Files

**Symptoms:** Builder modifies 50+ files, hits guardrail

**Solutions:**
1. Break task into smaller subtasks
2. Request OVERRIDE with justification (if legitimate)
3. Adjust file limit in builder.md for your project

---

### Issue: Tests Fail After Implementation

**Symptoms:** Builder creates code but tests fail

**Solutions:**
1. Review bug ticket generated by Builder
2. Apply suggested fixes manually or ask Builder to retry
3. Check if existing tests need updates (breaking change)

---

### Issue: High Token Costs

**Symptoms:** Running out of API budget quickly

**Solutions:**
1. Switch to cheaper models (see Configuration)
2. Reduce context attachments (only attach necessary folders)
3. Use Builder directly for simple tasks (skip Visual Designer)
4. Batch multiple small changes into one brief

---

### Issue: Accessibility Score Always Low

**Symptoms:** QA always reports a11y <85

**Solutions:**
1. Install proper a11y tools (axe-core, eslint-plugin-jsx-a11y)
2. Provide accessibility requirements in brief
3. Train Visual Designer with examples of accessible components
4. Manual audit and document patterns for agents to follow

---

## 🤝 Contributing

### Reporting Issues

Found a bug or have a suggestion?

1. Check existing issues: [GitHub Issues](#)
2. Create new issue with:
   - Agent name
   - Reproduction steps
   - Expected vs actual behavior
   - Cursor version, OS, model used

### Submitting Improvements

Have an idea to improve agents?

1. Fork repository
2. Make changes to agent .md files
3. Test thoroughly with real projects
4. Submit PR with:
   - Clear description of change
   - Example showing improvement
   - Any breaking changes noted

### Sharing Configurations

Built a great config for a specific stack (Flutter, Next.js, etc.)?

Share your config in Discussions → Configurations

---

## 📚 Additional Resources

### Related Documentation
- [Cursor AI Documentation](https://cursor.sh/docs)
- [Master Orchestrator Deep Dive](./master-orchestrator.md)
- [Visual Designer Deep Dive](./visual-designer.md)
- [Builder Deep Dive](./builder.md)
- [QA Reviewer Deep Dive](./qa-reviewer.md)

### Example Projects
- [React Example](./examples/react-example.md)
- [iOS Example](./examples/ios-example.md)
- [Django Example](./examples/django-example.md)

### Community
- Discord: [Join our community](#)
- Twitter: [@cursor_agents](#)
- Blog: [cursor-agents.dev/blog](#)

---

## 📄 License

MIT License - see LICENSE file for details

---

## 🙏 Acknowledgments

Built with inspiration from:
- [Anthropic's Claude](https://www.anthropic.com/)
- [OpenAI's GPT-4](https://openai.com/)
- [Cursor IDE](https://cursor.sh/)
- The amazing developer community

---

**Version:** 1.0  
**Last Updated:** January 15, 2025  
**Maintainers:** [Your Name/Team]

---

**Happy coding with AI agents! 🚀**

