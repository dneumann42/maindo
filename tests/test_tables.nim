import unittest, strutils

import ../src/markdown

suite "Markdown table parsing":
  test "We can read and write tables":
    const code = """
| Name                  | Artist            | Rating |
|-----------------------|-------------------|--------|
| Exercises in Futility | Mgla              | 5.0    |
| Reflektor             | Arcade Fire       | 4.65   |
| Vicious Delicious     | Infected Mushroom | 4.5    |
    """.strip()
    let doc = parseBlocks(code)
    let a = $doc.blocks[0]
    check a == code
