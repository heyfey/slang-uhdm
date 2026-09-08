// r10uvm210 grid arm A — EVERY DEFAULT FORM a package parameter can carry, in
// the DECLARING package (the "home"), so the def-view Rhs FORM table can be read
// off one golden: literal, expression, bare sibling reference, enum constant,
// qualified cross-package reference, string, and a TYPED one of each.
package p210a_src;
  parameter S_LIT = 9;
  typedef enum int { A_E0 = 3, A_E1 = 4 } a_e_t;
endpackage
package p210a;
  parameter        A_LIT      = 5;            // literal
  parameter int    A_TLIT     = 6;            // typed literal
  parameter        A_EXPR     = A_LIT + 1;    // expression over a sibling
  parameter        A_REF      = A_LIT;        // BARE sibling reference
  parameter int    A_TREF     = A_TLIT;       // typed bare sibling reference
  parameter        A_REFREF   = A_REF;        // reference to a reference
  parameter        A_REFEXPR  = A_EXPR;       // reference to an expression param
  parameter        A_QUAL     = p210a_src::S_LIT;   // qualified cross-package
  parameter        A_ENUM     = p210a_src::A_E1;    // ENUM CONSTANT default
  parameter        A_STR      = "keep";
  parameter        A_PAREN    = (A_LIT);      // parenthesised reference
endpackage
module m210a;
endmodule
