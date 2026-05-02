---
name: analyze-codebase
description: Regenereer .claude/codebase_analysis.md op basis van de actuele repository
area: workflow
provides:
  - codebase_analysis
depends_on:
  - config/project.md
---

# Analyze Codebase

Genereer een actuele `.claude/codebase_analysis.md` uit de werkelijke repository. Overschrijf de bestaande analyse alleen nadat discovery is uitgevoerd.

## When to Use

- Gebruiker roept `/analyze-codebase` aan
- Na structurele wijzigingen aan pagina's, Docker, prompts of project-layout
- Wanneer `codebase_analysis.md` verouderd lijkt

## Discovery

Run read-only discovery voor:

- `find ./website -type f -not -path "*/node_modules/*" | sort`
- HTML/CSS/JS/PHP/assets aantallen
- `find .claude -maxdepth 3 -type f | sort`
- `find .ai -maxdepth 3 -type f | sort`
- `find docker -maxdepth 3 -type f | sort`
- color tokens, spacing tokens, breakpoints en font families uit `website/css/style.css`
- zichtbare PHP-beschermingen in `website/contact-submit.php`
- Composer/Docker bestanden

## Output File

Schrijf `.claude/codebase_analysis.md` met:

1. Project overview
2. Tech stack tabel met actuele versies waar zichtbaar
3. Bestandsstructuur boom
4. Pagina-flow diagram
5. Design system
6. Contactformulier backend
7. AI-harnassing structuur
8. Root-utilities
9. Wat hier niet is

## Definition of Done

- Discovery is gebaseerd op actuele bestanden
- `codebase_analysis.md` is overschreven
- Nieuwe of verwijderde directories zijn verwerkt
- Geen broncode gewijzigd
