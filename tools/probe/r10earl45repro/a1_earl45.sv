// r10earl45 — the vpiSize grid for NESTED UNPACKED-ARRAY assignment patterns.
//
// The Earlgrey head (prim_keccak.sv 52:5, ELAB view) is an op75 nested one
// level inside a localparam's op75, whose elements are LEAF CONSTANTS, and
// golden stamps |vpiSize:32 on it.  Our code stamps a nested op ONLY when its
// elements are themselves sub-arrays (ExprEmit ~14625), so the keccak row gets
// nothing.  Every module below is a TOP (nothing instantiates it), so each one
// appears in BOTH listings: allModules (def) and topModules (elab).
//
// Every cell asks ONE question and carries its own control.

// A — the EXACT keccak shape: int [5][5] read through a doubly-nested genvar
//     select.  This is the head reproduced outside Earlgrey.
module a45_keccak;
  localparam int T [5][5]  = '{
    '{   0,  36,   3, 105, 210},
    '{   1, 300,  10,  45,  66},
    '{ 190,   6, 171,  15, 253},
    '{  28,  55, 153,  21, 120},
    '{  91, 276, 231, 136,  78}
  };
  for (genvar x = 0 ; x < 5 ; x++) begin : gx
    for (genvar y = 0 ; y < 5 ; y++) begin : gy
      localparam int Off = T[x][y]%32;
    end
  end
endmodule

// B — the SAME table with NO use site anywhere.  Separates "the size is a
//     property of the pattern" from "the size is a side effect of folding a
//     select at a use site".
module b45_nouse;
  localparam int T [5][5]  = '{
    '{   0,  36,   3, 105, 210},
    '{   1, 300,  10,  45,  66},
    '{ 190,   6, 171,  15, 253},
    '{  28,  55, 153,  21, 120},
    '{  91, 276, 231, 136,  78}
  };
endmodule

// C — two rows, no use.  Is the stamp on the FIRST operand only, on FIRST and
//     LAST, or on every row?
module c45_two;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
endmodule

// D — two rows, a single use that reads a cell of the LAST row only.  If the
//     stamp follows the use, row 1 gets it and row 0 does not.
module d45_userow1;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
  localparam int U = T[1][2];
endmodule

// E — two rows, a single use that reads a cell of the FIRST row only.
module e45_userow0;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
  localparam int U = T[0][2];
endmodule

// F — THREE levels.  The already-measured shape (commit 6f04dd8): the middle
//     ops are stamped with the leaf width, the innermost (leaf-constant
//     elements) gets nothing.  Does the innermost stay unstamped here?
module f45_three;
  localparam int T [2][2][2] = '{'{'{1,2},'{3,4}},'{'{5,6},'{7,8}}};
endmodule

// G — FOUR levels.  THE DISCRIMINATOR between "depth 1 only" and "every level
//     except the innermost": they agree on 2 and 3 levels and disagree here.
module g45_four;
  localparam int T [2][2][2][2] =
      '{'{'{'{1,2},'{3,4}},'{'{5,6},'{7,8}}},
        '{'{'{9,10},'{11,12}},'{'{13,14},'{15,16}}}};
endmodule

// H — element type is BYTE (8 bits), two rows.  Is the stamped value the
//     ELEMENT width or a constant 32?
module h45_byte;
  localparam byte T [2][3] = '{'{1,2,3},'{4,5,6}};
endmodule

// I — element type is a 12-bit packed vector.
module i45_vec12;
  localparam logic [11:0] T [2][3] = '{'{1,2,3},'{4,5,6}};
endmodule

// J — a module PARAMETER rather than a localparam, same shape.
module j45_param #(parameter int T [2][3] = '{'{1,2,3},'{4,5,6}}) ();
endmodule

// K — DESCENDING ranges (the reorder path) rather than ascending [N].
module k45_desc;
  localparam int T [1:0][2:0] = '{'{1,2,3},'{4,5,6}};
endmodule

// L — a PACKED 2-D pattern (the ParameterPackedArray family) as the negative
//     control: this law must not touch it.
module l45_packed;
  localparam logic [1:0][3:0] T = '{4'h1, 4'h2};
endmodule

// M — one row only (single operand).
module m45_one;
  localparam int T [1][3] = '{'{1,2,3}};
endmodule

// N — the table lives in a PACKAGE, read from a module.
package n45_pkg;
  localparam int T [2][3] = '{'{1,2,3},'{4,5,6}};
endpackage
module n45_use;
  import n45_pkg::*;
  localparam int U = T[1][2];
endmodule

// O — a VARIABLE initializer rather than a parameter (suppressConstParent).
module o45_var;
  int V [2][3] = '{'{1,2,3},'{4,5,6}};
endmodule

// P — an unpacked array of PACKED arrays: the element of the outer pattern is
//     a sub-array in the TYPE but its own elements are leaf constants.
module p45_arrofvec;
  localparam logic [3:0][7:0] T [2] = '{'{8'h1,8'h2,8'h3,8'h4},
                                        '{8'h5,8'h6,8'h7,8'h8}};
endmodule
