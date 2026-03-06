# Assistentes de IA & Skills

A inteligência artificial transformou radicalmente a maneira como escrevemos código. No entanto, os LLMs (grandes modelos de linguagem) normalmente são treinados com dados desatualizados ou não conhecem a fundo as nuances e melhores práticas de frameworks específicos e mais contemporâneos.

Para resolver este problema e fornecer uma experiência de desenvolvimento (DX) de classe mundial, o ecossistema Dext inclui nativamente um conjunto de **Skills** (habilidades/instruções).

Estas **Skills** são arquivos de instrução (no estilo System Prompts e _few-shot examples_) desenhados especificamente para ensinar o seu Agente de IA favorito (Cursor, Antigravity, Copilot, Claude CLI, Cline, etc) a abstrair a DSL (Domain Specific Language) do Dext, garantindo código idiomático, limpo e livre de "alucinações" usando bibliotecas ou padrões obsoletos do Delphi.

---

## 🛠️ Como Utilizar as Skills do Dext

Os arquivos de Skill estão localizados no diretório base do repositório:
`Docs/ai-agents/skills/`

Existem diversas formas de configurar o seu workspace ou agente para consumi-los, dependendo de qual ferramenta você utiliza.

### Opção 1: Cópia Direta para o Projeto (Mais Simples)

A abordagem mais universal é simplesmente copiar o diretório de skills para dentro da pasta do seu projeto/workspace raiz que está sendo analisado pela IA. Diferentes assistentes leem pastas com padrões ocultos na raiz do seu repositório:

1. Vá até o diretório `Docs/ai-agents/skills` do Dext.
2. Copie os arquivos relevantes (ou a pasta inteira).
3. Cole na raiz do seu projeto dentro da pasta correspondente ao seu assistente:
   - **Claude Code**: `.claude/skills/`
   - **Cursor**: `.cursor/rules/` (ou `.agents/skills/` dependendo da versão do agente)
   - **Cline / OpenCode / Antigravity**: `.agents/skills/`

### Opção 2: Configuração Global Customizada (Recomendado para Antigravity)

Alguns agentes state-of-the-art, como o Antigravity, permitem que você aponte caminhos locais no seu disco sem a necessidade de poluir os seus repositórios de trabalho copiando pastas.

1. Abra a interface de **Configuração / Settings** do seu Agente.
2. Navegue até o caminho: **Antigravity User Settings > Customizations > Customize Global Skills**.
3. Em **Skill Custom Paths**, clique em **Add** e aponte para a pasta descompactada do Dext em sua máquina:
   Ex: `C:\dev\Dext\DextRepository\Docs\ai-agents\skills`

*(Desta forma, independentemente do projeto Dext que você esteja trabalhando, seu assistente sempre carregará as diretrizes precisas e atualizadas do framework.)*_

### Opção 3: Symlinks (Links Simbólicos)

Para manter as regras sempre sincronizadas com qualquer pull/atualização que você fizer do repositório original do Dext (sem precisar ficar copiando arquivos novamente), você pode criar um **Link Simbólico** do seu projeto apontando para a pasta local de documentação do Dext.

**No Windows (Rodar como Administrador):**

```cmd
cd MeuProjeto
md .agents
mklink /D .agents\skills C:\dev\Dext\DextRepository\Docs\ai-agents\skills
```

**No macOS/Linux:**

```bash
cd MeuProjeto
mkdir -p .agents
ln -s /path/to/DextRepository/Docs/ai-agents/skills .agents/skills
```

---

## 📚 O que esperar?

Quando seu agente/assistente analisa as Skills do Dext, o comportamento sugerido passa de código Delphi genérico (e muitas vezes com forte acoplamento no paradigma antigo) para a **arquitetura limpa do Dext**:

- Sugestões para Minimal APIs e injeção de dependência via atributos corretamente.
- Utilização segura das abstrações em `Dext.Entity` usando "Smart Properties" ao invés de strings cruas nos filtros LINQ do ORM.
- Model Binding mágico com o uso nativo dos Responses tipados.
- Criação de estruturas como `TStartup` para configurar o Container de DI do sistema.

**Dica de Ouro:** Não é necessário carregar dezenas de prompts de uma vez. As skills do Dext foram modularizadas em pedaços atômicos para poupar tokens de contexto das requests (ex: `dext-web.md`, `dext-orm.md`, `dext-auth.md`). Invoque-os conforme o cenário de desenvolvimento da sua feature atual!
