◯ Documentation

# Types
A type can be one of the following:
- The unit                  `◯`
- A sum of two types        `α⊕β`
- A product of two types    `α×β`

Note that `×` has a higher precedence than `⊕`, similar to `*` and `+` in regular arithmetic. To control precedence, wrap expressions in chevron brackets : `⟨⟩`

The fact that `×` distributes over `⊕` is not taken advantage of, and expressions are left unsimplified according to how the user has defined them.

# Type Functions
A type function accepts types and other type functions in order to return a type. A type function is defined entirely in one line. Lines are separated by Greek Question Mark (U+037E) and no newlines.

A type function is named with a single kanji character (Unicode range U+4E00 to U+9FFF).

This is followed by the function's definition.
The definition consists of the function's argument separated by an arrow (covered later), with the return type after the arrow. The argument must be a type, represented with a single lowercase greek letter (Unicode range U+03B1 to U+03C9).

Type function application is simply the function and the types separated by a Fullwidth Dollar Sign (U+FF04). It has a higher precedence than both `⊕` and `×`. For example,

`例＄α`

passes the value `α` to the function `例`.

# Arrows
The arrows in the definition of the function type can be either `⇀` or `⇁`.
Whenever applicable, `⇀` is biased towards the left halves of the product and sum types that come before and after it respectively. Similarly, `⇁` is biased towards the right halves of the product and sum types that come before and after it respectively.

# 主
A valid ◯ program defines a single type function called `主`. It has the same syntax as other type functions.

One argument is provided in the command line.
When the program is run, the provided value (syntax described later) is coerced into the type described by the function body using a specific series of steps (described in the next section), and then the final value is displayed to the user.

# Coercion
The heart of ◯ is the fact that _a function can be infered entirely from its type._ The behaviour for all possible combinations of two types are given below:

- `◯   ⇀ ◯`       Trivial.
- `◯   ⇀ γ⊕δ`     Coerces `◯` to `γ`.
- `◯   ⇀ γ×δ`     Coerces `◯` to `γ` and `◯` to `δ`, and puts them in a pair.
- `α⊕β ⇀ ◯`       Trivial.
- `α⊕β ⇀ γ⊕δ`     Coerces `α` to `γ` or `β` to `δ`.
- `α⊕β ⇀ γ×δ`     Coerces `α` to `γ×δ` or `β` to `γ×δ`.
- `α×β ⇀ ◯`       Trivial.
- `α×β ⇀ γ⊕δ`     Coerces `α` to `γ⊕δ`.
- `α×β ⇀ γ×δ`     Coerces `α` to `γ` and `β` to `δ`.
- `◯   ⇁ ◯`       Trivial.
- `◯   ⇁ γ⊕δ`     Coerces `◯` to `δ`.
- `◯   ⇁ γ×δ`     Coerces `◯` to `γ` and `◯` to `δ`, and puts them in a pair.
- `α⊕β ⇁ ◯`       Trivial.
- `α⊕β ⇁ γ⊕δ`     Coerces `α` to `γ` or `β` to `δ`.
- `α⊕β ⇁ γ×δ`     Coerces `α` to `γ×δ` or `β` to `γ×δ`.
- `α×β ⇁ ◯`       Trivial.
- `α×β ⇁ γ⊕δ`     Coerces `β` to `γ⊕δ`.
- `α×β ⇁ γ×δ`     Coerces `α` to `γ` and `β` to `δ`.

# Values
The following syntax is for values that inhabit types, which are only seen when passing input to the program or receiving output from it.
- The unit                        `U`
- A product of two values         `P (x) (y)`
- The left value in a sum type    `L (x)`
- The right value in a sum type   `R (x)`

Parentheses are not required if `x` or `y` is `U`.

For example, a value inhabiting a type ⟨◯⊕◯⟩×⟨◯⊕◯⟩ may look like `P (L U) (R U)`.