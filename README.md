# Syntax

```
program
    : expression*
    ;

expression
    : command
    | call
    ;

command
    : value INFIX-COMMAND expression
    | '(' COMMAND expression* ')'
    ;

call
    : '(' expression* ')' 
    | value
    ;

value
    : number
    | boolean
    | string
    | symbol
    ;
```
