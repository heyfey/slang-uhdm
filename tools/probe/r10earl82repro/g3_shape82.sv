// r10earl82 g3 — THE BOUND-SYNTAX axis at the RANGE consumer.  MEASUREMENT ONLY.
package pk3_82;
  localparam int PI = 8;
  localparam int PJ = 4;
endpackage

module m3_82 import pk3_82::*; (input logic clk, output logic o);
  localparam int LI = 8;              // module localparam, int
  localparam     LU = 8;              // module localparam, untyped
  logic [PI:0]        s_bare;         // bare package param
  logic [pk3_82::PI:0] s_qual;        // QUALIFIED package param
  logic [LI:0]        s_lbare;        // bare module localparam
  logic [LU:0]        s_lu;           // untyped module localparam
  logic [PI-1:0]      s_minus;        // an EXPRESSION bound
  logic [PI+1:0]      s_plus;
  logic [PI*2:0]      s_mul;
  logic [$clog2(PI)-1:0] s_clog;
  logic [PI:PJ]       s_both;         // BOTH bounds parameters
  logic [7:0]         s_lit;          // a written literal
  logic [(PI):0]      s_paren;        // a PARENTHESISED bare read
  assign o = clk ^ s_bare[0] ^ s_qual[0] ^ s_lbare[0] ^ s_lu[0] ^ s_minus[0] ^
             s_plus[0] ^ s_mul[0] ^ s_clog[0] ^ s_both[4] ^ s_lit[0] ^ s_paren[0];
endmodule
