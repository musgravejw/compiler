Compiler ![Build Status](https://travis-ci.org/musgravejw/compiler.svg?branch=master)
========
This is a project written in Ruby to demonstrate compiler theory concepts.
The compiler is a single pass LL(1) recursive descent compiler built from a custom grammar.

## Usage
`rake` will build everything in the 'tests' dir.

`rake clean` to clear 'target' dir.

```
compiler
    ├── README.md
    ├── compiler.rb
    ├── rakefile
    ├── src
    │   ├── code_gen.rb
    │   ├── parser.rb
    │   ├── runtime.rb
    │   ├── scanner.rb
    │   └── semantic.rb
    └── tests
        └── correct
            ├── fromJake.src
            ├── test_heap.src
            ├── test_program.src
            ├── test_program_array.src
            ├── test_program_minimal.src
            └── test_program_with_errors.src

3 directories, 14 files
```

## Language
```
<program> ::=
    <program_header> <program_body>

<program_header> ::=
    program <identifier> is

<program_body> ::=
        ( <declaration> ; )*
    begin
        ( <statement> ; )*
    end program

<declaration> ::=
    [ global ] <procedure_declaration>
    [ global ] <variable_declaration>

<variable_declaration> ::=
    <type_mark> <identifier> [ [ <array_size> ] ]

<type_mark> ::=
    integer |
    float |
    bool |
    string

<procedure_declaration> ::=
    <procedure_header> <procedure_body>

<procedure_header> ::=
    procedure <identifier> ( [ <parameter_list> ] )

<procedure_body> ::=
        ( <declaration> ; )*
    begin
        ( <statement ; )*
    end procedure

<parameter_list> ::=
    <parameter> , <parameter_list> |
    <parameter>

<parameter> ::=
    <variable_declaration> ( in | out )

<statement> ::=
    <assignment_statement> |
    <if_statement> |
    <loop_statement> |
    <return_statement> |
    <procedure_call>

<assignment_statement> ::=
    <destination> := <expression>

<if_statement> ::=
    if ( <expression> ) then ( <statement> ; )+
    [ else ( <statement> ; )+ ]
    end if

<loop_statement> ::=
    for ( <assignment_statement> ; <expression> )
        ( <statement> ; )*
    end for

<procedure_call> ::=
    <identifier> ( [ <argument_list> ] )

<argument_list> ::=
    <expression> , <argument_list> |
    <expression>

<destination> ::=
    <identifier> [ [ <expression> ] ]

<expression> ::=
    <expression> & <arith_op> |
    <expression> | <arith_op> |
    [ not ] <arith_op>

<arith_op> ::=
    <arith_op> + <relation> |
    <arith_op> - <relation> |
    <relation>

<relation> ::=
    <relation> < <term> |
    <relation> > <term> |
    <relation> >= <term> |
    <relation> <= <term> |
    <relation> == <term> |
    <relation> != <term> |
    <term>

<term> ::=
    <term> * <factor> |
    <term> / <factor> |
    <factor>

<factor> ::=
    ( <expression> ) |
    [ - ] <name> |
    [ - ] <number> |
    <string> |
    true |
    false |

<name> ::=
    <identifier> [ [ <expression> ] ]

<identifier> ::=
    [a-zA-Z][a-zA-Z0-9_]*

<number> ::=
    [0-9][0-9_]*[.[0-9_]*]?

<string> ::=
    "[a-zA-Z0-9 _,;:.]*"
```

## Author
Written by [John Musgrave](http://johnmusgrave.com).

## License
Licensed under the [MIT License](https://github.com/musgravejw/compiler/blob/master/LICENSE)
