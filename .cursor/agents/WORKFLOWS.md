# Example Workflows

Complete end-to-end workflows showing how to use the agent system for common development scenarios.

---

## Table of Contents

1. [New Feature Development](#1-new-feature-development)
2. [Bug Fixes](#2-bug-fixes)
3. [Performance Optimization](#3-performance-optimization)
4. [Accessibility Remediation](#4-accessibility-remediation)
5. [Refactoring](#5-refactoring)
6. [Design System Updates](#6-design-system-updates)
7. [API Integration](#7-api-integration)
8. [Testing Improvements](#8-testing-improvements)

---

## 1. New Feature Development

### Scenario: Build a Search Autocomplete Component

**Objective:** Create a production-ready search input with autocomplete suggestions, keyboard navigation, and accessibility features.

#### Step-by-Step Workflow

**Step 1: Initiate with Master Orchestrator**
```
You: @Master_Orchestrator Build a search autocomplete component

Requirements:
- Input field with debounced search
- Dropdown showing max 10 suggestions
- Keyboard navigation (Arrow keys, Enter, Escape)
- Click outside to close
- Accessibility: ARIA attributes, screen reader support
- Responsive: works on mobile and desktop
- Performance: debounce 300ms, virtual scrolling for many results
- Design: use tokens from /design/tokens.json
```

**Step 2: Master Creates Plan**
```
Master Orchestrator:

NORMALIZED BRIEF
----------------
Build search autocomplete component with debounced input (300ms), 
dropdown showing ≤10 suggestions, full keyboard navigation, 
ARIA support, responsive design, and virtual scrolling.

EXECUTION PLAN
--------------
Task 1 [Visual Designer]
- Context: @design/tokens.json, @components/inputs, @components/dropdowns
- Input: Brief + existing input/dropdown patterns
- Output: 3 visual variants (minimal, rich, compact)
- Files: 0 (design only)
- Budget: High quality, 30k tokens

Task 2 [Builder]
- Context: @src/components, @tests/unit, @hooks
- Input: Approved variant + interaction specs
- Output: Component + tests + PR
- Files: ~12 files (max 25)
- Budget: Balanced, 20k tokens

Task 3 [QA Reviewer]
- Context: PR branch, test commands
- Input: Branch name
- Output: Scorecard + merge decision
- Files: 0 (review only)
- Budget: Mixed, 25k tokens

CHECKPOINT
----------
Ready to dispatch Task 1 to Visual Designer.
This will generate 3 design variants (~30k tokens).

Reply with APPROVE to proceed.
```

**Step 3: Approve Visual Design Phase**
```
You: APPROVE
```

**Step 4: Visual Designer Delivers Variants**
```
Visual Designer:

CONSTRAINTS
-----------
375px mobile, 1440px desktop | A11y ≥85/100 | Touch: Autocomplete component

VARIANT A: Minimal Inline Dropdown
-----------------------------------
Rationale: Clean, simple dropdown directly below input. 
Mobile-optimized with large touch targets.

[Component scaffold, tokens, a11y score: 92/100]

VARIANT B: Rich Suggestions with Icons
---------------------------------------
Rationale: Includes icons, categories, and keyboard shortcuts display.
Better discoverability but more complex.

[Component scaffold, tokens, a11y score: 88/100]

VARIANT C: Compact Search Bar
------------------------------
Rationale: Dense, Google-style search. Minimal visual weight.

[Component scaffold, tokens, a11y score: 90/100]

COMPARISON TABLE
----------------
| Variant | Visual | A11y   | Complexity | Rec |
|---------|--------|--------|------------|-----|
| A       | High   | 92/100 | Simple     | ✅  |
| B       | High   | 88/100 | Complex    | No  |
| C       | Medium | 90/100 | Medium     | No  |

RECOMMENDATION: Variant A
Best balance of accessibility, simplicity, and visual impact.

EXPORT PACKAGE: [Tokens, component files, assets, handoff notes]
```

**Step 5: Select Variant**
```
Master: Which variant would you like to implement?

You: Approve variant A
```

**Step 6: Builder Implements**
```
Master: CHECKPOINT - Task 2: Builder
        Ready to implement Variant A.
        Reply with APPROVE to proceed.

You: APPROVE

Builder:

CONFIRMED
---------
Implementing: Variant A (Minimal Inline Dropdown)
Branch: agent/builder/search-autocomplete-789
Context: src/components/Autocomplete, tests/unit

IMPLEMENTATION LOG
------------------
[Commit 1] feat: Add Autocomplete component structure
[Commit 2] feat: Implement debounced search hook
[Commit 3] feat: Add keyboard navigation logic
[Commit 4] feat: Implement ARIA attributes and focus management
[Commit 5] test: Add comprehensive test suite
[Commit 6] docs: Add component documentation

TEST RESULTS
------------
✅ PASSED
Linter: 0 errors, 0 warnings
Unit tests: 58/58 passing (12 new tests)
Coverage: 94% (+3%)

PR DRAFT
--------
Title: Add search autocomplete component with keyboard navigation

[Full PR body with screenshots, test status, review items]

FILES CHANGED (12 total)
+ src/components/Autocomplete/Autocomplete.tsx (156 lines)
+ src/components/Autocomplete/Autocomplete.module.css (78 lines)
+ src/hooks/useDebounce.ts (24 lines)
+ src/hooks/useKeyboardNav.ts (89 lines)
+ tests/unit/Autocomplete.test.tsx (134 lines)
[... 7 more files]

STATUS: READY FOR QA
```

**Step 7: QA Review**
```
Master: CHECKPOINT - Task 3: QA Reviewer
        Reply with APPROVE to proceed.

You: APPROVE

QA Reviewer:

SCORECARD
---------
| Category           | Score | Status  |
|--------------------|-------|---------|
| Functional Tests   | 100   | ✅ PASS |
| Accessibility      | 94    | ✅ PASS |
| Visual Regression  | 100   | ✅ PASS |
| Performance        | 96    | ✅ PASS |
| Security           | 100   | ✅ PASS |
| Code Quality       | 100   | ✅ PASS |

Overall: 98/100

DETAILED RESULTS
----------------
✅ All 58 tests passing
✅ Accessibility: 94/100 (above threshold)
   - 0 critical issues
   - 1 minor: Consider adding aria-live region for suggestion count
✅ Performance: Debounce working, no unnecessary re-renders
✅ Keyboard nav: All scenarios tested (Tab, Arrow, Enter, Escape)

MERGE RECOMMENDATION: ✅ READY

Conditions:
- Human code review
- Optionally add aria-live for suggestion count (nice-to-have)

Next: Reply APPROVE to merge agent/builder/search-autocomplete-789 → staging
```

**Step 8: Final Approval**
```
Master: FINAL REPORT
        All tasks completed successfully.
        MERGE RECOMMENDATION: READY
        
        Reply with APPROVE to merge.

You: APPROVE

Master: ✅ Task marked for merge.
        Branch: agent/builder/search-autocomplete-789
        Target: staging
        
        Audit Log:
        - Task 1 (Visual Designer): 28,234 tokens, 5m 12s
        - Task 2 (Builder): 22,156 tokens, 8m 34s
        - Task 3 (QA): 12,445 tokens, 3m 18s
        Total: 62,835 tokens, 17m 4s (~$0.18)
```

**Result:**
- ✅ Production-ready Autocomplete component
- ✅ 12 files with 58 tests (94% coverage)
- ✅ Accessibility score: 94/100
- ✅ Performance optimized (debouncing, virtual scroll)
- ✅ Full documentation
- ⏱️ Completed in ~17 minutes
- 💰 Cost: ~$0.18

---

## 2. Bug Fixes

### Scenario: Fix Form Validation Error

**Problem:** Email validation rejects valid emails containing "+" character (e.g., user+test@example.com)

#### Workflow

**Step 1: Report Bug**
```
You: @Master_Orchestrator Fix email validation bug in login form

Issue: Emails with + character are rejected as invalid
Example: user+test@example.com fails validation
Expected: Should accept all valid RFC 5322 emails
Location: src/components/LoginForm/LoginForm.tsx
```

**Step 2: Master Creates Fix Plan**
```
Master:

NORMALIZED BRIEF
----------------
Fix email regex in LoginForm to accept + character and all RFC 5322 valid formats.

EXECUTION PLAN
--------------
Task 1 [Builder] (Skip Visual Designer - bug fix only)
- Fix regex pattern
- Add test case for + character
- Add test cases for other edge cases (dots, hyphens, etc.)
- Files: ~3 files

Task 2 [QA Reviewer]
- Verify fix works
- Check no regressions

CHECKPOINT: Ready to dispatch to Builder
Reply APPROVE to proceed.
```

**Step 3: Builder Fixes Bug**
```
You: APPROVE

Builder:

CONFIRMED
---------
Fixing: Email validation regex bug
Branch: agent/builder/email-validation-fix-456

IMPLEMENTATION LOG
------------------
[Commit 1] fix: Update email regex to accept + character

File: src/components/LoginForm/LoginForm.tsx
Lines: 45-47

Change:
-const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
+const emailRegex = /^[a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

[Commit 2] test: Add test cases for email validation edge cases

Added tests:
- Email with + character (user+test@example.com)
- Email with multiple dots (first.last@example.com)
- Email with hyphens (user-name@example.com)
- Email with numbers (user123@example.com)

TEST RESULTS
------------
✅ PASSED
Unit tests: 52/52 passing (4 new)
New tests all green ✅

FILES CHANGED (3)
~ src/components/LoginForm/LoginForm.tsx (+1, -1)
~ tests/unit/LoginForm.test.tsx (+24, -0)
~ docs/validation-rules.md (+5, -2)
```

**Step 4: QA Verifies**
```
You: APPROVE

QA:

SCORECARD: 100/100
All tests passing
No regressions detected
Fix verified: user+test@example.com now validates correctly

RECOMMENDATION: ✅ READY
```

**Step 5: Merge**
```
You: APPROVE

Master: ✅ Bug fix ready to merge
        Time: 4m 23s
        Cost: ~$0.08
```

**Result:**
- ✅ Bug fixed with test coverage
- ✅ No regressions
- ✅ Documentation updated
- ⏱️ 4 minutes
- 💰 $0.08

---

## 3. Performance Optimization

### Scenario: Optimize Slow Dashboard

**Problem:** Dashboard loads in 5.2 seconds, target is <2.5s

#### Workflow

**Step 1: Request Optimization**
```
You: @Master_Orchestrator Optimize dashboard performance

Current metrics:
- LCP: 5.2s (target <2.5s)
- FID: 180ms (target <100ms)
- CLS: 0.15 (target <0.1)
- Bundle size: 2.4MB gzipped

Focus areas:
- Code splitting
- Lazy loading
- Image optimization
- Remove unused dependencies
```

**Step 2: QA Analyzes Current State**
```
Master: Task 1: QA Reviewer baseline audit

You: APPROVE

QA:

BASELINE AUDIT
--------------
Performance Score: 42/100

Issues Found:
1. Large bundle (2.4MB) - no code splitting
2. All images loaded upfront (12 large PNGs)
3. Blocking scripts (analytics, chat widget)
4. Unused dependencies (lodash, moment.js can be tree-shaken)
5. No lazy loading for below-fold content

Recommendations:
- Implement React.lazy() for routes
- Convert images to WebP, add lazy loading
- Defer non-critical scripts
- Replace heavy libraries (moment → date-fns)
- Use dynamic imports for modals
```

**Step 3: Builder Implements Optimizations**
```
You: APPROVE

Builder:

OPTIMIZATION LOG
----------------
[Commit 1] perf: Add React.lazy for route components
[Commit 2] perf: Implement lazy loading for images
[Commit 3] perf: Convert images to WebP format
[Commit 4] perf: Defer analytics and chat widget
[Commit 5] perf: Replace moment.js with date-fns
[Commit 6] perf: Dynamic imports for modals

Changes Summary:
- Routes: Lazy-loaded 8 route components
- Images: Converted 12 PNGs to WebP (2.1MB → 420KB)
- Scripts: Deferred 3 non-critical scripts
- Dependencies: Removed moment.js (-289KB)
- Code split: 6 dynamic imports for modals

TEST RESULTS
------------
✅ All tests passing
Bundle size: 2.4MB → 890KB (63% reduction)
```

**Step 4: QA Validates Improvements**
```
You: APPROVE

QA:

POST-OPTIMIZATION AUDIT
-----------------------
Performance Score: 94/100 🎉

New Metrics:
- LCP: 2.1s (was 5.2s) ✅ 60% improvement
- FID: 58ms (was 180ms) ✅ 68% improvement
- CLS: 0.04 (was 0.15) ✅ 73% improvement
- Bundle: 890KB (was 2.4MB) ✅ 63% reduction

All targets met!

RECOMMENDATION: ✅ READY

Monitoring recommendations:
- Watch bundle size in CI (set limit at 1MB)
- Monitor LCP in production (alert if >3s)
- Track lazy loading errors
```

**Result:**
- ✅ 60% LCP improvement (5.2s → 2.1s)
- ✅ 63% bundle size reduction
- ✅ All Core Web Vitals passing
- ⏱️ 18 minutes
- 💰 $0.22

---

## 4. Accessibility Remediation

### Scenario: Fix Navigation Menu Accessibility

**Problem:** Navigation menu fails WCAG AA audit

#### Workflow

```
You: @Master_Orchestrator Fix navigation menu accessibility issues

Current problems:
- No keyboard navigation
- Missing ARIA labels
- Color contrast 2.8:1 (need 4.5:1)
- Screen reader doesn't announce menu state
- Focus not managed when menu opens

Target: WCAG AA compliant (≥85/100)
```

**Audit → Fix → Validate:**

**QA Initial Audit:**
- Score: 58/100
- 12 violations (2 critical, 6 serious, 4 moderate)

**Builder Fixes:**
- Add keyboard handlers (Tab, Enter, Escape, Arrow keys)
- Implement ARIA (role="navigation", aria-expanded, aria-label)
- Update colors (4.6:1 contrast)
- Add focus trap when menu open
- Manage focus on open/close

**QA Final Audit:**
- Score: 100/100
- 0 violations
- Manual screen reader test: ✅

**Result:**
- ✅ WCAG AA compliant
- ✅ Full keyboard navigation
- ✅ Screen reader compatible
- ⏱️ 12 minutes
- 💰 $0.15

---

## 5. Refactoring

### Scenario: Extract Shared Logic into Custom Hook

**Goal:** Refactor 5 components using duplicated fetch logic into shared `useFetch` hook

#### Workflow

```
You: @Master_Orchestrator Refactor fetch logic into custom hook

Current state:
- 5 components (UserProfile, PostList, CommentSection, Dashboard, Settings)
- Each has duplicated fetch logic (loading, error, retry, cache)
- Inconsistent error handling

Goal:
- Create useFetch hook with TypeScript generics
- Migrate all 5 components
- Maintain existing behavior (no breaking changes)
- Add tests for hook
```

**Builder Creates Hook:**
```typescript
// src/hooks/useFetch.ts
export function useFetch<T>(url: string, options?: FetchOptions) {
  // Handles loading, error, retry, caching
}
```

**Builder Migrates Components:**
- Update 5 components to use hook
- Remove duplicated code (~200 lines removed)
- Add comprehensive hook tests
- Verify no behavior changes

**QA Validates:**
- All existing tests pass
- No regressions
- Bundle size: -15KB (less duplication)

**Result:**
- ✅ DRY principle applied
- ✅ 200 lines of code removed
- ✅ Easier to maintain
- ⏱️ 14 minutes

---

## 6. Design System Updates

### Scenario: Update Button Component with New Variants

**Goal:** Add new button variants (outline, ghost, danger) while maintaining backward compatibility

#### Workflow

```
You: @Master_Orchestrator Update Button component with new variants

New variants needed:
- outline (transparent with border)
- ghost (transparent, no border)
- danger (red for destructive actions)

Requirements:
- Maintain existing primary/secondary variants
- Backward compatible (no breaking changes)
- Update design tokens
- Add to Storybook
- Full accessibility
```

**Visual Designer:**
- Creates 3 design variants for new button types
- Provides token updates
- Ensures color contrast for all states

**Builder:**
- Adds new variants to Button component
- Updates TypeScript types
- Adds Storybook stories
- Migrates 3 example usages

**QA:**
- Tests all variants (10 variants × 3 states = 30 combinations)
- Accessibility: all pass
- Visual regression: approved changes

**Result:**
- ✅ 3 new button variants
- ✅ Backward compatible
- ✅ Fully documented in Storybook
- ⏱️ 16 minutes

---

## 7. API Integration

### Scenario: Integrate Stripe Payment API

**Goal:** Add Stripe Checkout integration to e-commerce app

#### Workflow

```
You: @Master_Orchestrator Integrate Stripe Checkout

Requirements:
- Create checkout session on backend
- Display Stripe-hosted checkout page
- Handle success/cancel redirects
- Store payment status in database
- Send confirmation email
- Error handling and retries

Endpoints needed:
- POST /api/checkout/create-session
- GET /api/checkout/success?session_id=xxx
- GET /api/checkout/cancel
```

**Builder Creates:**

**Backend (3 endpoints):**
```typescript
// api/checkout/create-session.ts
export async function createCheckoutSession(req, res) {
  const session = await stripe.checkout.sessions.create({...});
  res.json({ sessionId: session.id });
}

// api/checkout/success.ts
export async function handleSuccess(req, res) {
  const { session_id } = req.query;
  // Verify payment, update DB, send email
}

// api/checkout/cancel.ts
export async function handleCancel(req, res) {
  // Log cancellation, redirect to cart
}
```

**Frontend (Checkout button):**
```tsx
<CheckoutButton
  onCheckout={async () => {
    const { sessionId } = await createSession();
    await stripe.redirectToCheckout({ sessionId });
  }}
/>
```

**Tests:**
- API endpoint tests (mocked Stripe)
- Frontend interaction tests
- Error handling tests
- Webhook tests (for payment confirmation)

**QA Validates:**
- All flows tested (success, cancel, error)
- Security: API keys in env vars, not hardcoded
- Error handling: network failures, invalid cards

**Result:**
- ✅ Full Stripe integration
- ✅ Production-ready with error handling
- ✅ Tests cover all scenarios
- ⏱️ 24 minutes
- 💰 $0.28

---

## 8. Testing Improvements

### Scenario: Increase Test Coverage from 65% to 90%

**Goal:** Add tests to under-tested modules

#### Workflow

```
You: @Master_Orchestrator Increase test coverage to 90%

Current coverage: 65%
Target: 90%

Priority modules:
1. Authentication (current: 45%)
2. Payment processing (current: 52%)
3. User management (current: 60%)
4. API error handling (current: 38%)
```

**QA Analyzes Gaps:**
```
COVERAGE ANALYSIS
-----------------
Total: 65%

Gaps:
1. auth/login.ts: 45% (missing: error handling, edge cases)
2. payments/stripe.ts: 52% (missing: webhook tests, retries)
3. users/crud.ts: 60% (missing: validation tests)
4. api/errors.ts: 38% (missing: all error types)

Recommended tests: 47 new tests
Est. coverage after: 92%
```

**Builder Adds Tests:**
- auth/login.test.ts: +12 tests (45% → 95%)
- payments/stripe.test.ts: +18 tests (52% → 94%)
- users/crud.test.ts: +9 tests (60% → 91%)
- api/errors.test.ts: +8 tests (38% → 96%)

**QA Validates:**
```
FINAL COVERAGE
--------------
Total: 92% (was 65%) ✅

Module breakdown:
- Authentication: 95% ✅
- Payments: 94% ✅
- Users: 91% ✅
- API Errors: 96% ✅

47 new tests added
All passing ✅
```

**Result:**
- ✅ Coverage: 65% → 92%
- ✅ 47 new tests
- ✅ Better confidence in critical modules
- ⏱️ 22 minutes
- 💰 $0.25

---

## Summary of Workflows

| Workflow | Time | Cost | Files Changed | Tests Added | Outcome |
|----------|------|------|---------------|-------------|---------|
| New Feature (Autocomplete) | 17m | $0.18 | 12 | 58 | ✅ 98/100 |
| Bug Fix (Email Validation) | 4m | $0.08 | 3 | 4 | ✅ 100/100 |
| Performance Optimization | 18m | $0.22 | 15 | 0 | ✅ 60% faster |
| Accessibility Fix | 12m | $0.15 | 4 | 8 | ✅ WCAG AA |
| Refactoring (Custom Hook) | 14m | $0.16 | 6 | 12 | ✅ -200 LOC |
| Design System Update | 16m | $0.19 | 8 | 15 | ✅ New variants |
| API Integration (Stripe) | 24m | $0.28 | 18 | 23 | ✅ Production-ready |
| Test Coverage Increase | 22m | $0.25 | 4 | 47 | ✅ 65%→92% |

**Average:**
- Time: ~16 minutes
- Cost: ~$0.19 per workflow
- Quality: 95+ scores consistently

---

## Tips for Success

1. **Be Specific:** More details in briefs = better results
2. **Review Each Step:** Don't blindly approve everything
3. **Iterate:** Give feedback if output isn't quite right
4. **Start Small:** Test with simple tasks first
5. **Monitor Costs:** Track token usage in audit logs
6. **Customize:** Adjust agents for your tech stack

---

**Ready to build faster with AI agents? Start with a simple feature and iterate from there! 🚀**

