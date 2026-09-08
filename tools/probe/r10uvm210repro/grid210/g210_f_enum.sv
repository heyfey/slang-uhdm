// r10uvm210 grid arm F — ENUM-CONSTANT defaults, which is what the brief named
// ("golden keeps the reference to the enum constant with the defining operation
// as its actual").  A package-local enum, a same-package bare member reference,
// a qualified one, and a member reference from an IMPORTING package.
package p210f;
  typedef enum int { F_RED = 1, F_GREEN = 2 } f_e_t;
  parameter        F_BARE  = F_GREEN;
  parameter        F_QUAL  = p210f::F_RED;
  parameter f_e_t  F_TYPED = F_GREEN;
  parameter        F_EXPR  = F_GREEN + 1;
endpackage
package p210f_imp;
  import p210f::*;
  parameter FI_BARE = F_GREEN;
endpackage
module m210f;
  import p210f::*;
endmodule
