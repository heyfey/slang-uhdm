// r10uvm77 VERIFIER ARM x1 — THE `with` CLAUSE WITHOUT PARENTHESES.
//
// The EMPTY PRODUCT CELL the implementer's grid never filled.  IEEE 1800
// randomize_call makes the argument list OPTIONAL in front of a `with`
// constraint block:
//     randomize_call ::= randomize [ ( ... ) ] [ with [ ( ... ) ] constraint_block ]
// so `o.randomize with { … }` is PARENS-LESS but is emphatically still a CALL.
// The shipped probe scans forward from the method-name token for `(` and finds
// `w` — it reads PARENS-LESS.  Site 1 is fenced by `!withExpr9`, but withExpr9
// is only ever set from `getIteratorInfo()` (the ARRAY-LOCATOR `with`), never
// from a randomize constraint block.
//
// Cells 1/2 are the law's question; 3/4 are the parens-ful positive controls.
class x1c;
  rand int a;
  rand int b;
  constraint cc { a > 0; }
endclass

module top77x1;
  int r;
  x1c o;
  initial begin
    o = new();
    r = o.randomize with { a > 5; };          // (1) PARENS-LESS + with block
    r = r + o.randomize() with { a > 6; };    // (2) parens-ful + with block
    r = r + o.randomize();                    // (3) parens-ful control
    r = r + o.randomize;                      // (4) parens-less, no with
    $display("%0d", r);
  end
endmodule
