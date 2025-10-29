# Quick Start Guide 🚀

Get up and running with Cursor Agents in 10 minutes!

---

## ⚡ 5-Minute Setup

### Step 1: Copy Agent Files (1 minute)

The agent prompt files are already in `.cursor/agents/`:
- ✅ `master-orchestrator.md`
- ✅ `visual-designer.md`
- ✅ `builder.md`
- ✅ `qa-reviewer.md`

### Step 2: Create Agents in Cursor (3 minutes)

Open Cursor and create 4 agents:

**Agent 1: Master Orchestrator**
```
Name: Master Orchestrator
System Prompt: [Paste contents of master-orchestrator.md]
Model: claude-3-haiku (or gpt-3.5-turbo)
Temperature: 0.3
Max Tokens: 5000
```

**Agent 2: Visual Designer**
```
Name: Visual Designer
System Prompt: [Paste contents of visual-designer.md]
Model: claude-3-opus (or gpt-4)
Temperature: 0.7
Max Tokens: 30000
```

**Agent 3: Builder**
```
Name: Builder
System Prompt: [Paste contents of builder.md]
Model: claude-3-sonnet (or gpt-4)
Temperature: 0.5
Max Tokens: 20000
```

**Agent 4: QA Reviewer**
```
Name: QA Reviewer
System Prompt: [Paste contents of qa-reviewer.md]
Model: claude-3-haiku (or gpt-3.5-turbo)
Temperature: 0.3
Max Tokens: 25000
```

### Step 3: Test with Simple Task (1 minute)

```
@Master_Orchestrator Create a simple Button component with primary and secondary variants
```

Expected response:
- Master creates execution plan
- Asks for APPROVE
- You type: APPROVE
- Workflow proceeds automatically

If this works → ✅ You're ready!

---

## 🎯 Your First Real Task (5 minutes)

Try building a complete component:

```
@Master_Orchestrator Build a responsive Card component

Requirements:
- Image, title, description, and action button
- Mobile (375px) and desktop (1440px) layouts
- Hover animations
- Accessibility: WCAG AA compliant
- Include tests
```

**What happens:**

1. **Master Orchestrator** → Creates 3-task plan
2. **Visual Designer** → Generates 3 design variants
3. You choose a variant → Approve
4. **Builder** → Implements code + tests
5. **QA Reviewer** → Runs checks
6. **Master** → Reports READY
7. You approve → Ready to merge!

**Time:** ~10-15 minutes  
**Cost:** ~$0.20  
**Result:** Production-ready component with tests

---

## 📚 What's Next?

### Learn More

1. **Full Documentation:** Read [README.md](./README.md) for complete guide
2. **Example Workflows:** See [WORKFLOWS.md](./WORKFLOWS.md) for 8 detailed examples
3. **Configuration:** Check [CONFIG.md](./CONFIG.md) for customization options

### Common Use Cases

**New Feature:**
```
@Master_Orchestrator Build a [component] with [requirements]
```

**Bug Fix:**
```
@Master_Orchestrator Fix [issue description] in [file/component]
```

**Performance:**
```
@Master_Orchestrator Optimize [page/component] to improve [metric]
```

**Accessibility:**
```
@Master_Orchestrator Fix accessibility issues in [component]
```

**Refactoring:**
```
@Master_Orchestrator Refactor [code description] to [improvement]
```

---

## 💡 Pro Tips

### 1. Always Start with Master
❌ `@Builder Add a button`  
✅ `@Master_Orchestrator Add a button component`

### 2. Be Specific
❌ `Make it better`  
✅ `Improve performance by implementing code splitting and lazy loading`

### 3. Review Before Approving
Don't blindly type APPROVE. Review:
- Design variants make sense
- Code follows your patterns
- Tests cover important cases

### 4. Use APPROVE Keyword
Agents wait for the exact word: `APPROVE`

Other commands:
- `APPROVE MERGE` - Merge to protected branch
- `OVERRIDE` - Override guardrails
- `PAUSE` - Stop execution
- `ABORT` - Cancel task

---

## 🐛 Troubleshooting

### "Agent doesn't respond"
- Check agent is enabled in Cursor Settings
- Try mentioning with @AgentName
- Restart Cursor

### "Command not found"
Add missing commands to package.json:
```json
{
  "scripts": {
    "audit:a11y": "axe --dir dist",
    "lighthouse": "lighthouse http://localhost:3000"
  }
}
```

### "Too many files changed"
- Break task into smaller subtasks
- Or request OVERRIDE with justification

### "High token costs"
- Use cheaper models (gpt-3.5-turbo)
- Reduce context attachments
- Skip Visual Designer for simple tasks

---

## 📊 What to Expect

### Typical Results

| Task Type | Time | Cost | Quality Score |
|-----------|------|------|---------------|
| Simple component | 5-10 min | $0.08-0.15 | 95-100/100 |
| Complex feature | 15-25 min | $0.20-0.35 | 90-98/100 |
| Bug fix | 3-5 min | $0.05-0.10 | 100/100 |
| Performance optimization | 15-20 min | $0.20-0.30 | Varies |
| Refactoring | 10-15 min | $0.15-0.25 | 95-100/100 |

### Success Metrics

After 10 tasks, you should see:
- ✅ 95%+ test pass rate
- ✅ 85%+ accessibility scores
- ✅ Consistent code quality
- ✅ Faster development cycles
- ✅ Better documentation

---

## 🎓 Learning Path

### Week 1: Basics
- Day 1-2: Simple components (Button, Input, Card)
- Day 3-4: Bug fixes and small features
- Day 5: Accessibility improvements

### Week 2: Intermediate
- Day 1-2: Complex components (Autocomplete, Modal, Carousel)
- Day 3-4: API integrations
- Day 5: Performance optimization

### Week 3: Advanced
- Day 1-2: Design system updates
- Day 3-4: Large refactoring
- Day 5: Custom agent configurations

---

## 🚀 Ready to Build?

Try this workflow right now:

```
@Master_Orchestrator Build a Toast notification component

Requirements:
- Success, error, warning, info variants
- Auto-dismiss after 5 seconds
- Positioned top-right
- Slide-in animation
- Accessible (aria-live region)
- Stack multiple toasts
- Mobile responsive
```

Watch the magic happen! ✨

---

**Questions?** Check [README.md](./README.md) or [WORKFLOWS.md](./WORKFLOWS.md)

**Ready to go deeper?** See [CONFIG.md](./CONFIG.md) for customization

---

**Happy building with AI agents! 🤖💙**

