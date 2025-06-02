import unittest, strutils

import ../src/markdown

suite "Markdown parsing":
  test "We can read and write tables":
    const code = """
    | Name                  | Artist            | Rating |
    |-----------------------|-------------------|--------|
    | Exercises in Futility | Mgla              | 5.0    |
    | Reflektor             | Arcade Fire       | 4.65   |
    | Vicious Delicious     | Infected Mushroom | 4.5    |
    """.strip().unindent()
    let doc = parseBlocks(code)
    let a = $doc.blocks[0]
    check a == code

  test "We can fill in missing columns":
    const code = """
    | A | X | Y |
    |---|---|---|
    | 1 | 3 |
    """.strip().unindent()
    let doc = parseBlocks(code)
    let a = $doc.blocks[0]
    let b = """
    | A | X | Y |
    |---|---|---|
    | 1 |   | 3 |
    """.strip().unindent()
    check a == b

  test "We can read and write headings":
    const code = """
    # Hello
    ## World
    ### Testing
    #### Headings
    """.strip().unindent()

    let doc = parseBlocks(code)
    for i in 1 .. 4:
      check doc.blocks[i - 1].level == i
    let a = ($doc).strip()
    check a == code

  test "We can read code blocks":
    const code = """
    ```py
    def hello():
      print("Hello!")
    ```
    """.strip().unindent()

    let doc = parseBlocks(code)
    check $doc == code
