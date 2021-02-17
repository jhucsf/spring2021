---
layout: default
title: "Assignment 2: Postfix calculator"
---

*Note: this assignment description will be updated soon to describe detailed grading criteria*

*Update 2/10* — Fixed the `curl` command showing how to download the skeleton code

*Update 2/11* — Updated skeleton code to include missing [runTest.rb](assign02/runTest.rb) script

*Update 2/12* — Clarify that `eval` function should be implemented in `cPostfixCalcEval.c` and `asmPostfixCalcEval.S`

*Update 2/12* — Mention missing `Makefile` dependency and how to fix

*Update 2/16* — Detailed grading criteria for Milestones 1 and 2 are available

Milestone 1 ([Task 1](#task-1-c-implementation-of-the-postfix-calculator) and [Task 2](#task-2-system-tests-for-the-c-postfix-calculator)): due Thurs, Feb 18th by 11pm

Milestone 2: ([Task 3](#task-3-implementation-of-assembly-language-functions) started): due Thurs, Feb 25th by 11pm

Milestone 3 ([Task 3](#task-3-implementation-of-assembly-language-functions) and optional [Task 4](#task-4-optional-implement-the-main-function-is-assembly-language)): due Thurs, Mar 4th by 11pm

# Overview

In this assignment, you will implement a postfix calculator program in C and x86-64 assembly language.

Milestone 1 grading breakdown (20% of assignment grade):

* `cPostfixCalc` functionality: 10%
* Correctness of individual functions: 10%

Milestone 2 grading breakdown (10% of assignment grade):

* Unit tests of assembly language functions: 1%
* At least 1 assembly language function fully working: 2%
* At least 2 assembly language functions fully working: 2%
* At least 3 assembly language functions fully working: 1%
* At least 4 assembly language functions fully working: 1%
* At least 5 assembly language functions fully working: 1%
* At least 6 assembly language functions fully working: 1%
* At least 7 assembly language functions fully working: 1%

Milestone 3 grading breakdown (70% of assignment grade):

* Coming soon!

This is a challenging assignment.  Don't wait until the last minute to
start it!  As usual, ask questions using Piazza, come to office hours,
etc.

**Important**: When you write assembly code, you must *actually* write
assembly code. Using the compiler to generate assembly code is *not*
allowed.  In addition, we expect *highly detailed* code comments; in
assembly lanuage programs, it's not unusual for *every* line of code to
be commented.

When you are done with this assignment you will have proved yourself
capable of writing nontrivial x86-64 assembly code.  This is a
foundational skill for hacking on operating systems and compilers,
understanding security vulnerabilities such as buffer overflows, and
generally becoming one with the machine.

## Getting started

Get started by downloading [csf\_assign02.zip](csf_assign02.zip) and
extracting it using the `unzip` command.

You can download this file from a Linux command prompt using the `curl` command:

```bash
curl -O https://jhucsf.github.io/spring2021/assign/csf_assign02.zip
```

Note that in the `-O` option, it is the letter "O", not the numeral "0".

*Update 2/11* — The [runTest.rb](assign02/runTest.rb) script and the
[calctest.rb] were originally missing from the zipfile. If you need to download them to your
project, run the following commands:

```bash
curl -O https://jhucsf.github.io/spring2021/assign/assign02/runTest.rb
chmod a+x runTest.rb
curl -O https://jhucsf.github.io/spring2021/assign/assign02/calctest.rb
```

*Update 2/12* — The original `Makefile` was missing a dependency on line.  Originally, it read

```
cTests : cTests.o tctest.o cPostfixCalcFuncs.o
```

You should modify it to be

```
cTests : cTests.o tctest.o cPostfixCalcFuncs.o cPostfixCalcEval.o
```

# Postfix arithmetic

Normally when we express arithmetic we use *infix notation*, where
binary operators (such as +, -, etc.) are placed between their operands.
For example, to expression the addition of the operands 2 and 3, we
would write

> `2 + 3`

In *postfix notation* the operator comes *after* the operands, so adding
2 and 3 would be written

> `2 3 +`

Postfix notation has some advantages over infix notation: for example,
parentheses are not necessary, since the order of operations is
never ambiguous.  Postfix notation is also called [Reverse Polish
notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation).
It is famously used in [HP calculators](https://en.wikipedia.org/wiki/HP_calculators)
and programming languages such as
[Forth](https://en.wikipedia.org/wiki/Forth_(programming_language)) and
[PostScript](https://en.wikipedia.org/wiki/PostScript).

Evaluating postfix expressions using a program is very simple.
The program maintains a stack of values (initially empty).  The items
(operands and operators) in the expression are processed in order.
Operands (e.g., literal values) are pushed onto the stack.  When an
operator is encountered, its operand values are popped from the stack,
the operator is applied to the operand values, and the result value is
pushed onto the stack.  For example, consider the postfix expression

> `3 4 5 + *`

This expression would be evaluated as follows:

Item | Action
---- | ------
`3`  | Push 3 onto stack
`4`  | Push 4 onto stack
`5`  | Push 5 onto stack
`+`  | Pop operands 5 and 4, add them, push sum 9
`*`  | Pop operands 9 and 3, multiply them, push product 27

When any valid postfix expression is evaluated, the stack will have a
single result value when the end of the expression is reached.  Also,
valid postfix expressions will guarantee that operand values are always
available on the stack when an operator is processed.  Here are some
examples of *invalid* postfix expressions:

Expression | Why invalid
---------- | -----------
`10 2 - *` | Only one operand value is on stack when operator \* is processed
`2 3 + 4`  | Two operand values are on stack when end of expression is reached

# Tasks

## Task 1: C implementation of the postfix calculator

The C version of the postfix calculator consists of three source files:

* `cPostfixCalcMain.c`: This file contains the `main` function of the
  postfix calculator. This is provided for you. You should not modify
  this file.
* `cPostfixCalcFuncs.c`: This file contains implementations of functions
  to implement the postfix caculator, with the exception of the `eval`
  function.
* `cPostfixCalcEval.c`: This file contains the implementation of the `eval` function.

Each function in `cPostfixCalcFuncs.c` and `cPostfixCalcMain.c` has
detailed comments describing the expected behavior of the function.

The functions you are required to implement are:

```c
void fatalError(const char *msg);
int isSpace(int c);
int isDigit(int c);
const char *skipws(const char *s);
int tokenType(const char *s);
const char *consumeInt(const char *s, long *val);
const char *consumeOp(const char *s, int *op);
void stackPush(long stack[], long *count, long val);
long stackPop(long stack[], long *count);
long evalOp(int op, long left, long right);
long eval(const char *s);
```

The header file `cPostfixCalc.h` contains the C function prototypes for
each required function, as well as definitions for the constant values
returned by the `tokenType` function.

The file `cTests.c` has reasonably extensive unit tests for each required
function.  You can build the unit test program by running the command

```
make cTests
```

and run the test program by running the command

```
./cTests
```

Once all of the functions are implemented, you can build the full
calculator program by running the command

```
make cPostfixCalc
```

You can run the C version of the postfix calculator program using a command of the form

<div class="highlighter-rouge"><pre>
./cPostfixCalc "<i>expression</i>"
</pre></div>

where *expression* is a postfix expression.  If the postfix expression
is valid, the program will print a line of output of the form

<div class="highlighter-rouge"><pre>
Result is: <i>N</i>
</pre></div>

where *N* is the result of evaluating the expression. If the postfix expression is invalid,
the program will print a line of output of the form

<div class="highlighter-rouge"><pre>
Error: <i>msg</i>
</pre></div>

where *msg* is an error message indicating why the evaluation failed.

The detailed requirements of how postfix expressions should be evaluated
and how the `cPostfixCalc` program should behave are as follows:

* The expression will consist of positive integer literals and operators (+, -, \*, and /)
* A sequence of one or more space (`' '`) or tab (`'\t'`) characters acts as a token separator
* Operators will not necessarily be separated from other tokens by
  whitespace: for example, `2 3 4 5 +-*` is a valid expression which when
  evaluated yields the result `-12`
* Leading and/or trailing whitespace should be ignored
* All values should be represented using signed 64-bit integers (use the `long` C data type)
* All operators should be evaluated using the usual C semantics for operations on `long` values
* The operand stack is limited to 20 values
* If the program successfully evaluates the input expression, it should exit with a zero (0) exit code

Here are some example invocations you can try from the command line:

Invocation | Expected output
---------- | ---------------
`./cPostfixCalc '1 1 +'` | `Result is: 2`
`./cPostfixCalc '7 2 -'` | `Result is: 5`
`./cPostfixCalc '3 4 5 + *'` | `Result is: 27`
`./cPostfixCalc '17 3 /'` | `Result is: 5`
`./cPostfixCalc '3 10 /'` | `Result is: 0`
`./cPostfixCalc '2 3 4 5 +-*'` | `Result is: -12`
`./cPostfixCalc '10 2 - *'` | `Error: ...`
`./cPostfixCalc '2 3 + 4'` | `Error: ...`

## Task 2: System tests for the C postfix calculator

To make sure that the C postfix calculator program works correctly,
you should write "system"-level tests to test the overall program
on various inputs.  Add these tests to **sysTests.sh**.  This script
supports two kinds of tests:

* `expect` runs the calculator program on a valid postfix expression and tests that the correct result is computed
* `expect_error` runs the calculator program on an invalid postfix expression and tests that an error message is printed

A few example tests are provided:

```bash
expect 5 '2 3 +'
expect 42 '6 7 *'
expect 42 '6 6 6 6 6 6 6 + + + + + +'
expect_error '2 2'
expect_error '1 *'
```

You should add your own tests.  As with the unit tests, try to think of
corner cases in your code, and add tests to exercise them.

To run the system tests on your C postfix calculator implementation, run the command

<div class="highlighter-rouge"><pre>
./sysTests.sh ./cPostfixCalc
</pre></div>

To help you generate some interesting tests, you may use the following
Ruby script: [gentest.rb](assign02/gentest.rb).  Example invocation:

```
$ ruby gentest.rb
expect 109 '4 15 7 * +'
```

Please note that these automatically-generated tests are *not* a
substitute for writing your own tests.  For example, the script only
generates valid postfix expressions, but you should also write tests
for various kinds of invalid expressions.

## Task 3: Implementation of assembly language functions

Once you have the C postfix calculator fully working, you can move on to reimplementing it
in x86-64 assembly language.  The requirements of this task are easy to describe:
for each function in `cPostfixCalcFuncs.c` and `cPostfixCalcEval.c`, you will need to
implement an equivalent function in `asmPostfixCalcFuncs.S` and `asmPostfixCalcEval.S`.

You can build and run the unit test program to test your assembly language
functions using the commands

<div class="highlighter-rouge"><pre>
make asmTests
./asmTests
</pre></div>

The unit tests will be *essential* in implementing the assembly language versions
of the functions.  They will allow you to implement and test each function separately.

You can build the assembly language version of the postfix calculator program
using the command

<div class="highlighter-rouge"><pre>
make asmPostfixCalc
</pre></div>

This program should behave identically to the <code>cPostfixCalc</code> program.
For example, the invocation

<div class="highlighter-rouge"><pre>
./asmPostfixCalc '2 3 4 5 +-&#42;'
</pre></div>

should print the output

<div class="highlighter-rouge"><pre>
Result is: -12
</pre></div>

You can run the system tasks you implemented in [Task 2](#task-2-system-tests-for-the-c-postfix-calculator)
against the assembly language postfix calculator using the command

<div class="highlighter-rouge"><pre>
./sysTests.sh ./asmPostfixCalc
</pre></div>



### Assembly language hints

Here are some hints that you should find useful as you implement the assembly
language functions:

*Start with the simplest functions.*  For example, you might start by implementing the
`isSpace` function, which should return 1 if its argument is space (`' '`)
or tab (`'\t'`), and return 0 otherwise.  The `isDigit` function is also a good place to start.

*Write the unit tests as you implement your functions.* Your job will
be *vastly* easier if you develop each function and its unit test(s)
at the same time.  You will find that unit tests allow you to test and
debug each function in isolation, and free you from having to worry
unnecessarily about interactions with other functions.

*Follow the calling conventions.* Make sure your assembly language
functions correctly adhere to the x86-64 calling conventions.  By doing
so,

* You will be able to call C library functions (such as `printf`) as needed
* You will be able to write your unit tests in C (i.e., you can make calls to your assembly language functions from the unit test code written in C)

Make sure that when your assembly code calls a function, the stack pointer
(`%rsp`) contains an address that is a multiple of 16.  Because a call
instruction pushes the current program counter value (`%rip`) onto the
stack, on entry to a function, the stack pointer is misaligned by 8 bytes
(the size of a code address), so each of your functions will need to
adjust `%rsp` by *N* bytes such that *N* mod 16 = 8.  I.e., subtract 8
bytes, or 24 bytes, or 40 bytes, etc.

*Use registers for local variables.*  For most local variables in your
code, you can use a register as the storage location.  The callee-saved
registers (`%rbx`, `%rbp`, `%r12`–`%r15`) are the most straightforward
to use, but you will need to save their previous contents and then
restore them before returning from the function.  (The `pushq` and
`popq` instructions make saving and restoring register contents easy.)
The caller-saved registers (`%r10` and `%r11`) don't need to be saved
and restored, but their values aren't preserved across function calls,
so they're tricker to use correctly.

*Use the frame pointer to keep track of local variables in memory.*
Some variables will need to be allocated in memory.  You can allocate
such variables in the stack frame of the called function.  The frame
pointer register (`%rbp`) can help you easily access these variables.
A typical setup for a function which allocates variables in the stack
frame would be something like

```
myFunc:
    pushq %rbp                      /* save previous frame pointer */
    subq $N, %rsp                   /* reserve space for local variable(s) */
    movq %rsp, %rbp                 /* set up frame pointer */

    /*
     * implementation of function: local variables can be accessed
     * relative to %rbp, e.g. 0(%rbp), 8(%rbp), etc.
     */

    addq $N, %rsp                   /* deallocate space for local variable(s) */
    popq %rbp                       /* restore previous frame pointer */
    ret
```

The code above allocates *N* bytes of memory in the stack frame for
local variables. Note that *N* needs to be a multiple of 16 to ensure
correct stack pointer alignment.  (Think about it!)

*Use `leaq` to compute addresses of local variables.* It is likely
that one or more of your functions takes a pointer to a variable as
a parameter.  When calling such a function, the `leaq` instruction
provides a very convenient way to compute the address of a variable.
For example, let's say we want to pass the address of a local variable
8 bytes offset from the frame pointer (`%rbp`) as the first argument to
a function.  We could load the address of this variable into the `%rdi`
register (used for the first function argument) using the instruction

```
leaq 8(%rbp), %rdi
```

*Use local labels starting with `.L` for flow control.*  As you implement
flow control (such as loops and decisions) in your program, you will
need to define labels for branch targets.  You should use names starting
with `.L` (period followed by capital L) for these labels.  This will
ensure that the assembler does not enter them into the symbol table as
function entry points, which will make debugging with `gdb` difficult.
Here is an example assembly language function with local labels:

```
/*
 * Determine the length of specified character string.
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *
 * Returns:
 *    number of characters in the string
 */
	.globl strLen
strLen:
	subq $8, %rsp                 /* adjust stack pointer */
	movq $0, %r10                 /* initial count is 0 */

.LstrLenLoop:
	cmpb $0, (%rdi)               /* found NUL terminator? */
	jz .LstrLenDone               /* if so, done */
	inc %r10                      /* increment count */
	inc %rdi                      /* advance to next character */
	jmp .LstrLenLoop              /* continue loop */

.LstrLenDone:
	movq %r10, %rax               /* return count */
	addq $8, %rsp                 /* restore stack pointer */
	ret
```

Note that the function above also illustrates what we consider to be an
appropriate amount of detail for code comments.

*Use cqto before idivq*.  Before using the `idivq` instruction to
do integer division, use the `cqto` instruction to sign extend the
dividend (which should be stored in the `%rax` register) into the `%rdx`
register. Download the [idiv.zip](assign02/idiv.zip) example program
for a full example.

## Task 4 (optional): Implement the main function is assembly language

When you build the `asmPostfixCalc` executable, it uses the C language version of
the `main` function defined in `cMain.c`.  This works because your assembly language
functions are semantically equivalent to their C language counterparts.

As optional extra credit, you may implement an assembly language version of the
`main` function.  It should follow the logic in the C `main` function.
To build the version of the postfix calculator program which is implemented in
pure assembly language, run the command

```
make asmPostfixCalc2
```

You can run your system tests against this version of the postfix calculator
using the command

```
./sysTests.sh asmPostfixCalc2
```

# Submitting

Before you submit, prepare a `README.txt` file so that it contains your
names, and briefly summarizes each of your contributions to the submission
(i.e., who worked on what functionality.) This may be very brief if you
did not work with a partner.

To submit your work:

Run the following commands to create a `solution.zip` file:

```
rm -f solution.zip
zip -9r solution.zip Makefile *.h *.c *.S *.sh README.txt
```

Upload `solution.zip` to [Gradescope](https://www.gradescope.com/) as **Assignment 2 MS1**,
**Assignment 2 MS2**, or **Assignment 2 MS3**, depending on which milestone you are submitting.

Please check the files you uploaded to make sure they are the ones you intended to submit.

## Autograder

When you upload your submission to Gradescope, it will be tested by
the autograder, which executes unit tests for each required function.
Please note the following:

* If your code does not compile successfully, all of the tests will fail
* The autograder runs `valgrind` on your code, but it does *not* report
  any information about the result of running `valgrind`: points will be
  deducted if your code has memory errors or memory leaks!
