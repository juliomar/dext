# AI Assistants & Skills

Artificial Intelligence has radically transformed the way we write code. However, LLMs (Large Language Models) are typically trained on outdated data or lack deep knowledge of the nuances and best practices of specific, contemporary frameworks.

To solve this problem and provide a world-class Developer Experience (DX), the Dext ecosystem natively includes a set of **Skills** (system prompts/instructions).

These **Skills** are instruction files designed specifically to teach your favorite AI Agent (Cursor, Antigravity, Copilot, Claude CLI, Cline, etc.) how to abstract Dext's DSL (Domain Specific Language). This guarantees idiomatic, clean code, free from "hallucinations" that use obsolete Delphi libraries or patterns.

---

## 🛠️ How to Use Dext Skills

The Skill files are located in the base directory of the repository:
`Docs/ai-agents/skills/`

There are several ways to configure your workspace or agent to consume them, depending on the tool you use.

### Option 1: Direct Copy to the Project (Simplest)

The most universal approach is to simply copy the skills directory into the root folder of your project/workspace being analyzed by the AI. Different assistants read hidden pattern folders at the root of your repository:

1. Go to the `Docs/ai-agents/skills` directory in Dext.
2. Copy the relevant files (or the entire folder).
3. Paste them into the root of your project within the folder corresponding to your assistant:
   - **Claude Code**: `.claude/skills/`
   - **Cursor**: `.cursor/rules/` (or `.agents/skills/` depending on the agent version)
   - **Cline / OpenCode / Antigravity**: `.agents/skills/`

### Option 2: Custom Global Configuration (Recommended for Antigravity)

Some state-of-the-art agents, like Antigravity, allow you to point to local paths on your disk without the need to pollute your working repositories by copying folders.

1. Open your Agent's **Configuration / Settings** interface.
2. Navigate to the following path: **Antigravity User Settings > Customizations > Customize Global Skills**.
3. Under **Skill Custom Paths**, click **Add** and point to your unzipped Dext folder:
   Example: `C:\dev\Dext\DextRepository\Docs\ai-agents\skills`

*(This way, regardless of the Dext project you are working on, your assistant will always load the precise and updated guidelines for the framework.)*

### Option 3: Symlinks (Symbolic Links)

To keep the rules constantly synchronized with any pull/update you make from the original Dext repository (without having to copy files again), you can create a **Symbolic Link** from your project pointing to the local Dext documentation folder.

**On Windows (Run as Administrator):**

```cmd
cd MyProject
md .agents
mklink /D .agents\skills C:\dev\Dext\DextRepository\Docs\ai-agents\skills
```

**On macOS/Linux:**

```bash
cd MyProject
mkdir -p .agents
ln -s /path/to/DextRepository/Docs/ai-agents/skills .agents/skills
```

---

## 📚 What to Expect?

When your agent/assistant parses the Dext Skills, the suggested behavior shifts from generic Delphi code (often with tight coupling in the legacy paradigm) to **Dext's clean architecture**:

- Suggestions for Minimal APIs and correct dependency injection via attributes.
- Safe utilization of `Dext.Entity` abstractions using "Smart Properties" instead of raw strings in ORM LINQ filters.
- Magical Model Binding leveraging native typed Responses.
- Generation of `TStartup` structures to set up the system's DI Container.

**Golden Tip:** It is not necessary to load dozens of prompts at once. Dext's skills have been modularized into atomic pieces to save context tokens on requests (e.g., `dext-web.md`, `dext-orm.md`, `dext-auth.md`). Invoke them according to the development scenario of your current feature!
