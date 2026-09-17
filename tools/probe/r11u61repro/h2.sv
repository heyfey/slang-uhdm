// r11u61 h2 — MEMBER WIDTHS x ELEMENT KINDS in the ELABORATED module copy.
// One module-local PACKED struct param per shape; every member a different
// width so "sized at the MEMBER width" is distinguishable from "sized at 32"
// and from "the first operand's width".
package p2;
  typedef enum logic [5:0] { E0 = 6'd9, E1 = 6'd10 } e2_t;
endpackage
module h2 import p2::*; (input logic clk);
  typedef struct packed {
    logic [3:0]  m4;
    logic [11:0] m12;
    logic [32:0] m33;
    logic [5:0]  m6;
  } s2_t;
  // WPLAIN: four unbased decimal literals — every operand reduces
  localparam s2_t WPLAIN = '{m4: 1, m12: 2, m33: 3, m6: 4};
  // WBASED: based literals of the WRONG width in every slot
  localparam s2_t WBASED = '{m4: 2'b11, m12: 8'hAB, m33: 4'd5, m6: 3'b101};
  // WENUM: an enum member in slot 2 and slot 4
  localparam s2_t WENUM  = '{m4: 1, m12: E0, m33: 2, m6: E1};
  // WCAT: a concatenation in slot 2
  localparam s2_t WCAT   = '{m4: 1, m12: {4'b1010, 4'b0101}, m33: 2, m6: 3};
  // WREP: a replication in slot 3
  localparam s2_t WREP   = '{m4: 1, m12: 2, m33: {3{1'b1}}, m6: 4};
  // WDEF: a default fill
  localparam s2_t WDEF   = '{m4: 1, default: 0};
  // WPOS: the POSITIONAL form
  localparam s2_t WPOS   = '{1, 2, 3, 4};
  wire x = clk ^ WPLAIN[0] ^ WBASED[0] ^ WENUM[0] ^ WCAT[0] ^ WREP[0]
                ^ WDEF[0] ^ WPOS[0];
endmodule
