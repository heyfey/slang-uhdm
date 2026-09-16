// r11v55 VERIFIER arm — ONE defaultSetter EXPRESSION, MANY MEMBER WIDTHS, and
// SIGNED / NEGATIVE values.  slang stores ONE `defaultSetter` Expression for
// the whole pattern; the law emits that ONE expression for EVERY member it
// fills and then restamps it to the member's width.  `default: '1` makes the
// value width-dependent (8 ones vs 16 ones vs 32 ones), and `default: -1` on
// a SIGNED member makes it sign-dependent, so this is where "one expression,
// many members" either holds or is visibly wrong.
package p;
  typedef struct packed {
    logic [7:0]   w8;
    logic [15:0]  w16;
    int unsigned  w32;
  } ones_t;
  localparam ones_t ONES = '{default: '1};
  typedef struct packed {
    int          s;     // SIGNED member, negative value
    int unsigned u;     // unsigned member, same literal
  } sgn_t;
  localparam sgn_t NEG = '{s: -1, u: 7};
endpackage
module dut #(parameter p::ones_t OO = p::ONES,
             parameter p::sgn_t  NN = p::NEG)
           (output logic [31:0] o_8, output logic [31:0] o_16,
            output logic [31:0] o_32, output logic signed [31:0] o_s,
            output logic [31:0] o_u);
  assign o_8  = OO.w8;
  assign o_16 = OO.w16;
  assign o_32 = OO.w32;
  assign o_s  = NN.s;    // negative -> SVInt::as<uint64_t> declines
  assign o_u  = NN.u;    // control
endmodule
