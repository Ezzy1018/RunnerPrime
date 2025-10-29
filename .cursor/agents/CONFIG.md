# Configuration Guide

Comprehensive configuration templates and customization options for the Cursor Agent system.

---

## Table of Contents

1. [Project Configuration](#project-configuration)
2. [Technology Stack Configurations](#technology-stack-configurations)
3. [Agent Model Settings](#agent-model-settings)
4. [Guardrail Customization](#guardrail-customization)
5. [CI/CD Integration](#cicd-integration)
6. [Custom Commands](#custom-commands)
7. [Performance Tuning](#performance-tuning)

---

## 1. Project Configuration

### Base Configuration Template

Create a `.cursor/config.json` file in your project root:

```json
{
  "project": {
    "name": "MyProject",
    "type": "web",
    "framework": "react",
    "language": "typescript"
  },
  "agents": {
    "enabled": true,
    "master_orchestrator": {
      "model": "gpt-4",
      "temperature": 0.3,
      "max_tokens": 5000
    },
    "visual_designer": {
      "model": "gpt-4",
      "temperature": 0.7,
      "max_tokens": 30000
    },
    "builder": {
      "model": "gpt-4",
      "temperature": 0.5,
      "max_tokens": 20000
    },
    "qa_reviewer": {
      "model": "gpt-3.5-turbo",
      "temperature": 0.3,
      "max_tokens": 25000
    }
  },
  "context": {
    "design_tokens": "/design/tokens.json",
    "source_directories": ["src", "components", "lib"],
    "test_directories": ["tests", "__tests__", "spec"],
    "config_files": ["package.json", "tsconfig.json", ".eslintrc.json"]
  },
  "guardrails": {
    "max_files_per_pr": 25,
    "accessibility_threshold": 85,
    "test_failure_threshold": 0.3,
    "protected_branches": ["main", "master", "production", "staging"]
  },
  "commands": {
    "test": "npm test",
    "lint": "npm run lint",
    "build": "npm run build",
    "audit_a11y": "npm run audit:a11y",
    "lighthouse": "npm run lighthouse",
    "security_scan": "npm audit"
  }
}
```

---

## 2. Technology Stack Configurations

### React + TypeScript + Vite

```json
{
  "project": {
    "name": "MyReactApp",
    "type": "web",
    "framework": "react",
    "language": "typescript",
    "bundler": "vite"
  },
  "context": {
    "design_tokens": "/src/styles/tokens.ts",
    "source_directories": ["src"],
    "component_directories": ["src/components", "src/features"],
    "test_directories": ["src/**/__tests__", "src/**/*.test.tsx"],
    "config_files": [
      "package.json",
      "tsconfig.json",
      "vite.config.ts",
      ".eslintrc.json",
      "vitest.config.ts"
    ]
  },
  "commands": {
    "test": "vitest run",
    "test_watch": "vitest",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "type_check": "tsc --noEmit",
    "build": "vite build",
    "audit_a11y": "axe --dir build --tags wcag2a,wcag2aa",
    "lighthouse": "lighthouse http://localhost:4173 --output=json --output-path=./lighthouse-report.json",
    "security_scan": "npm audit --audit-level=moderate"
  },
  "test_patterns": {
    "unit": "**/*.test.{ts,tsx}",
    "integration": "**/*.integration.test.{ts,tsx}",
    "e2e": "**/*.e2e.test.{ts,tsx}"
  }
}
```

### Next.js + TypeScript

```json
{
  "project": {
    "name": "MyNextApp",
    "type": "web",
    "framework": "nextjs",
    "language": "typescript"
  },
  "context": {
    "design_tokens": "/styles/tokens.ts",
    "source_directories": ["app", "components", "lib"],
    "test_directories": ["__tests__"],
    "config_files": [
      "package.json",
      "next.config.js",
      "tsconfig.json",
      ".eslintrc.json"
    ]
  },
  "commands": {
    "test": "jest",
    "test_watch": "jest --watch",
    "lint": "next lint",
    "type_check": "tsc --noEmit",
    "build": "next build",
    "audit_a11y": "axe http://localhost:3000",
    "lighthouse": "lighthouse http://localhost:3000 --chrome-flags='--headless'",
    "security_scan": "npm audit && next-secure-headers check"
  }
}
```

### Vue 3 + TypeScript

```json
{
  "project": {
    "name": "MyVueApp",
    "type": "web",
    "framework": "vue",
    "language": "typescript"
  },
  "context": {
    "design_tokens": "/src/assets/tokens.json",
    "source_directories": ["src"],
    "component_directories": ["src/components"],
    "test_directories": ["tests"],
    "config_files": [
      "package.json",
      "vite.config.ts",
      "tsconfig.json",
      ".eslintrc.js"
    ]
  },
  "commands": {
    "test": "vitest run",
    "lint": "eslint --ext .ts,.vue src",
    "type_check": "vue-tsc --noEmit",
    "build": "vite build",
    "audit_a11y": "vue-axe",
    "lighthouse": "lighthouse http://localhost:5173",
    "security_scan": "npm audit"
  }
}
```

### iOS/Swift + SwiftUI

```json
{
  "project": {
    "name": "MyiOSApp",
    "type": "mobile",
    "platform": "ios",
    "language": "swift",
    "framework": "swiftui"
  },
  "context": {
    "design_tokens": "DesignSystem/Tokens.swift",
    "source_directories": ["Sources", "Views", "Models", "Services"],
    "test_directories": ["Tests"],
    "config_files": [
      "Package.swift",
      ".swiftlint.yml",
      "Info.plist"
    ]
  },
  "commands": {
    "test": "swift test",
    "lint": "swiftlint lint --strict",
    "build": "swift build -c release",
    "audit_a11y": "# Manual using Accessibility Inspector",
    "security_scan": "# Use Xcode Analyze",
    "format": "swiftformat ."
  },
  "guardrails": {
    "max_files_per_pr": 20,
    "accessibility_threshold": 90,
    "test_failure_threshold": 0.2
  }
}
```

### Python + Django

```json
{
  "project": {
    "name": "MyDjangoApp",
    "type": "web",
    "framework": "django",
    "language": "python"
  },
  "context": {
    "source_directories": ["app", "core", "api"],
    "test_directories": ["tests"],
    "config_files": [
      "requirements.txt",
      "setup.py",
      "pyproject.toml",
      ".flake8"
    ]
  },
  "commands": {
    "test": "pytest",
    "test_coverage": "pytest --cov=app --cov-report=html",
    "lint": "flake8 app tests",
    "format": "black app tests",
    "type_check": "mypy app",
    "security_scan": "bandit -r app",
    "migrate": "python manage.py migrate"
  },
  "guardrails": {
    "max_files_per_pr": 30,
    "test_coverage_threshold": 80,
    "test_failure_threshold": 0.1
  }
}
```

### Node.js + Express (API)

```json
{
  "project": {
    "name": "MyExpressAPI",
    "type": "api",
    "framework": "express",
    "language": "typescript"
  },
  "context": {
    "source_directories": ["src"],
    "route_directories": ["src/routes", "src/controllers"],
    "test_directories": ["tests"],
    "config_files": [
      "package.json",
      "tsconfig.json",
      ".eslintrc.json"
    ]
  },
  "commands": {
    "test": "jest",
    "test_integration": "jest --testPathPattern=integration",
    "lint": "eslint src tests --ext .ts",
    "type_check": "tsc --noEmit",
    "build": "tsc",
    "security_scan": "npm audit && eslint-plugin-security",
    "api_test": "newman run tests/postman_collection.json"
  }
}
```

---

## 3. Agent Model Settings

### Budget-Conscious Setup (~$0.10/run)

Optimized for cost while maintaining reasonable quality.

```json
{
  "agents": {
    "master_orchestrator": {
      "model": "gpt-3.5-turbo",
      "temperature": 0.3,
      "max_tokens": 3000,
      "cost_per_1k_tokens": 0.0015
    },
    "visual_designer": {
      "model": "gpt-4",
      "temperature": 0.7,
      "max_tokens": 20000,
      "cost_per_1k_tokens": 0.03,
      "note": "Use GPT-4 only for design tasks; skip for non-visual work"
    },
    "builder": {
      "model": "gpt-3.5-turbo",
      "temperature": 0.5,
      "max_tokens": 15000,
      "cost_per_1k_tokens": 0.002
    },
    "qa_reviewer": {
      "model": "gpt-3.5-turbo",
      "temperature": 0.3,
      "max_tokens": 10000,
      "cost_per_1k_tokens": 0.0015
    }
  }
}
```

**Estimated cost per full run:** ~$0.10-0.12

### Balanced Setup (~$0.20/run) ⭐ Recommended

Best balance of cost and quality.

```json
{
  "agents": {
    "master_orchestrator": {
      "model": "claude-3-haiku-20240307",
      "temperature": 0.3,
      "max_tokens": 5000,
      "cost_per_1k_tokens": 0.00025
    },
    "visual_designer": {
      "model": "claude-3-opus-20240229",
      "temperature": 0.7,
      "max_tokens": 30000,
      "cost_per_1k_tokens": 0.015
    },
    "builder": {
      "model": "claude-3-sonnet-20240229",
      "temperature": 0.5,
      "max_tokens": 20000,
      "cost_per_1k_tokens": 0.003
    },
    "qa_reviewer": {
      "checks": {
        "model": "claude-3-haiku-20240307",
        "temperature": 0.3,
        "max_tokens": 10000
      },
      "fixes": {
        "model": "claude-3-sonnet-20240229",
        "temperature": 0.5,
        "max_tokens": 15000
      }
    }
  }
}
```

**Estimated cost per full run:** ~$0.18-0.25

### Premium Setup (~$0.40/run)

Maximum quality for critical projects.

```json
{
  "agents": {
    "master_orchestrator": {
      "model": "gpt-4-turbo-preview",
      "temperature": 0.3,
      "max_tokens": 5000
    },
    "visual_designer": {
      "model": "gpt-4-turbo-preview",
      "temperature": 0.7,
      "max_tokens": 30000
    },
    "builder": {
      "model": "gpt-4-turbo-preview",
      "temperature": 0.5,
      "max_tokens": 20000
    },
    "qa_reviewer": {
      "model": "gpt-4-turbo-preview",
      "temperature": 0.3,
      "max_tokens": 25000
    }
  }
}
```

**Estimated cost per full run:** ~$0.35-0.45

---

## 4. Guardrail Customization

### Strict Configuration

For critical production systems requiring high quality.

```json
{
  "guardrails": {
    "max_files_per_pr": 10,
    "accessibility_threshold": 95,
    "test_failure_threshold": 0.05,
    "test_coverage_threshold": 90,
    "performance_threshold": {
      "lighthouse_score": 90,
      "lcp_ms": 2000,
      "fid_ms": 50,
      "cls": 0.05
    },
    "security": {
      "block_on_high_severity": true,
      "block_on_medium_severity": true,
      "require_security_review": true
    },
    "code_quality": {
      "max_linter_warnings": 0,
      "max_complexity": 10,
      "max_function_length": 50
    },
    "protected_branches": ["main", "production", "staging", "develop"],
    "require_human_approval": {
      "db_migrations": true,
      "infrastructure_changes": true,
      "api_changes": true,
      "dependency_updates": true
    }
  }
}
```

### Balanced Configuration ⭐ Recommended

Reasonable standards for most projects.

```json
{
  "guardrails": {
    "max_files_per_pr": 25,
    "accessibility_threshold": 85,
    "test_failure_threshold": 0.3,
    "test_coverage_threshold": 75,
    "performance_threshold": {
      "lighthouse_score": 80,
      "lcp_ms": 2500,
      "fid_ms": 100,
      "cls": 0.1
    },
    "security": {
      "block_on_high_severity": true,
      "block_on_medium_severity": false,
      "require_security_review": false
    },
    "code_quality": {
      "max_linter_warnings": 5,
      "max_complexity": 15,
      "max_function_length": 100
    },
    "protected_branches": ["main", "production"],
    "require_human_approval": {
      "db_migrations": true,
      "infrastructure_changes": true,
      "api_changes": false,
      "dependency_updates": false
    }
  }
}
```

### Lenient Configuration

For rapid prototyping and early-stage projects.

```json
{
  "guardrails": {
    "max_files_per_pr": 50,
    "accessibility_threshold": 70,
    "test_failure_threshold": 0.5,
    "test_coverage_threshold": 60,
    "performance_threshold": {
      "lighthouse_score": 60,
      "lcp_ms": 4000,
      "fid_ms": 200,
      "cls": 0.2
    },
    "security": {
      "block_on_high_severity": true,
      "block_on_medium_severity": false,
      "require_security_review": false
    },
    "code_quality": {
      "max_linter_warnings": 20,
      "max_complexity": 20,
      "max_function_length": 150
    },
    "protected_branches": ["main"],
    "require_human_approval": {
      "db_migrations": false,
      "infrastructure_changes": false,
      "api_changes": false,
      "dependency_updates": false
    }
  }
}
```

---

## 5. CI/CD Integration

### GitHub Actions

`.github/workflows/agent-qa.yml`:

```yaml
name: Agent QA Checks

on:
  pull_request:
    branches: [main, staging]
    types: [opened, synchronize]

jobs:
  qa-review:
    runs-on: ubuntu-latest
    if: startsWith(github.head_ref, 'agent/builder/')
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Run linter
        run: npm run lint
        
      - name: Accessibility audit
        run: npm run audit:a11y
        
      - name: Lighthouse CI
        run: npm run lighthouse:ci
        
      - name: Security scan
        run: npm audit --audit-level=moderate
        
      - name: Check PR labels
        uses: actions/github-script@v6
        with:
          script: |
            const labels = context.payload.pull_request.labels.map(l => l.name);
            if (!labels.includes('agent:builder')) {
              throw new Error('PR from agent must have agent:builder label');
            }
            
      - name: Post QA report
        if: always()
        uses: actions/github-script@v6
        with:
          script: |
            // Post scorecard as PR comment
```

### GitLab CI

`.gitlab-ci.yml`:

```yaml
stages:
  - test
  - qa
  - deploy

agent-qa:
  stage: qa
  rules:
    - if: '$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ /^agent\/builder\//'
  script:
    - npm ci
    - npm test
    - npm run lint
    - npm run audit:a11y
    - npm run lighthouse
    - npm audit
  artifacts:
    reports:
      junit: test-results.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

---

## 6. Custom Commands

### package.json Scripts

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx}\"",
    "type-check": "tsc --noEmit",
    "build": "vite build",
    "audit:a11y": "axe --dir dist --tags wcag2a,wcag2aa --exit",
    "audit:lighthouse": "lighthouse http://localhost:4173 --output=json --output-path=./lighthouse-report.json",
    "audit:security": "npm audit --audit-level=moderate && snyk test",
    "visual-diff": "percy exec -- npm test -- --testPathPattern=visual",
    "agent:qa": "npm test && npm run lint && npm run audit:a11y && npm run build"
  }
}
```

---

## 7. Performance Tuning

### Token Budget Optimization

```json
{
  "optimization": {
    "context_attachments": {
      "mode": "smart",
      "max_files": 50,
      "exclude_patterns": [
        "node_modules",
        "dist",
        "build",
        "*.log",
        "*.lock"
      ],
      "prioritize": [
        "package.json",
        "README.md",
        "design/tokens.*"
      ]
    },
    "response_length": {
      "master_orchestrator": "concise",
      "visual_designer": "detailed",
      "builder": "balanced",
      "qa_reviewer": "detailed_for_failures_only"
    },
    "parallel_execution": {
      "enabled": true,
      "max_concurrent_agents": 2
    }
  }
}
```

---

## Complete Configuration Example

Save as `.cursor/agents-config.json`:

```json
{
  "version": "1.0",
  "project": {
    "name": "MyProject",
    "type": "web",
    "framework": "react",
    "language": "typescript"
  },
  "agents": {
    "enabled": true,
    "master_orchestrator": {
      "model": "claude-3-haiku-20240307",
      "temperature": 0.3,
      "max_tokens": 5000
    },
    "visual_designer": {
      "model": "claude-3-opus-20240229",
      "temperature": 0.7,
      "max_tokens": 30000
    },
    "builder": {
      "model": "claude-3-sonnet-20240229",
      "temperature": 0.5,
      "max_tokens": 20000
    },
    "qa_reviewer": {
      "model": "claude-3-haiku-20240307",
      "temperature": 0.3,
      "max_tokens": 25000
    }
  },
  "context": {
    "design_tokens": "/design/tokens.json",
    "source_directories": ["src", "components"],
    "test_directories": ["tests", "__tests__"],
    "config_files": ["package.json", "tsconfig.json", ".eslintrc.json"]
  },
  "commands": {
    "test": "npm test",
    "lint": "npm run lint",
    "build": "npm run build",
    "audit_a11y": "npm run audit:a11y",
    "lighthouse": "npm run lighthouse",
    "security_scan": "npm audit"
  },
  "guardrails": {
    "max_files_per_pr": 25,
    "accessibility_threshold": 85,
    "test_failure_threshold": 0.3,
    "test_coverage_threshold": 75,
    "protected_branches": ["main", "production"]
  },
  "optimization": {
    "context_attachments": {
      "mode": "smart",
      "max_files": 50
    }
  }
}
```

---

**Ready to configure your agents? Start with the balanced setup and customize based on your project needs! 🚀**

