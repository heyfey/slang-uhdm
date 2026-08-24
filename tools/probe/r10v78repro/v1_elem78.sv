// r10v78 arm v1 — the ELEMENT and COUNT ladder for § genCaReplWholeFold78.
// Every row appears TWICE with the SAME Lhs shape: once assigned from inside a
// gen-if scope to a MODULE-BODY signal (the HEAD's exact pairing), once in the
// module body itself (the already-landed twin).
package pk78;
  localparam int QN = 3;
endpackage
module v1;
  localparam int N   = 4;
  localparam logic [7:0] P8 = 8'hA5;
  logic [7:0]  sig8;
  logic [31:0] cvar = 32'h12345678;   // const-init, never written

  // module-body twin targets
  logic [31:0] m_hex, m_dec, m_par, m_cast, m_clog, m_pkg, m_op;
  logic [11:0] m_oct;
  logic [3:0]  m_sgn, m_one, m_cvar, m_sig;
  logic [7:0]  m_hexn;
  logic [2047:0] m_big;
  // gen-scope-assigned targets, DECLARED IN THE MODULE BODY
  logic [31:0] b_hex, b_dec, b_par, b_cast, b_clog, b_pkg, b_op;
  logic [11:0] b_oct;
  logic [3:0]  b_sgn, b_one, b_cvar, b_sig;
  logic [7:0]  b_hexn;
  logic [2047:0] b_big;

  assign m_hex   = {4{8'hFF}};        // E1  HEX element, natural 32
  assign m_oct   = {4{3'o7}};         // E2  OCT element, natural 12
  assign m_dec   = {4{8'd5}};         // E3  DEC element, natural 32
  assign m_par   = {4{P8}};           // E4  a PARAM ref element
  assign m_sgn   = {4{1'sb1}};        // E5  a SIGNED 1-bit element
  assign m_cast  = {4{2'(1'b1)}};     // E6  a CAST element
  assign m_one   = {1{1'b1}};         // E7  N == 1, 1-bit element
  assign m_clog  = {$clog2(16){1'b1}};// E8  N from $clog2
  assign m_pkg   = {pk78::QN{1'b1}};  // E9  a PACKAGE-parameter count
  assign m_big   = {2000{1'b1}};      // E10 N > 1000 (producer clamps at 1000)
  assign m_sig   = {4{sig8[0]}};      // E11 NON-constant element (must refuse)
  assign m_cvar  = {4{cvar[0]}};      // E12 a const-init never-written var
  assign m_op    = {4{1'b1}} | 32'h0; // E13 replication as ONE operand
  assign m_hexn  = {4{8'hFF}};        // E14 HEX, natural 32 -> target 8

  if (N > 0) begin : g1
    assign b_hex   = {4{8'hFF}};
    assign b_oct   = {4{3'o7}};
    assign b_dec   = {4{8'd5}};
    assign b_par   = {4{P8}};
    assign b_sgn   = {4{1'sb1}};
    assign b_cast  = {4{2'(1'b1)}};
    assign b_one   = {1{1'b1}};
    assign b_clog  = {$clog2(16){1'b1}};
    assign b_pkg   = {pk78::QN{1'b1}};
    assign b_big   = {2000{1'b1}};
    assign b_sig   = {4{sig8[0]}};
    assign b_cvar  = {4{cvar[0]}};
    assign b_op    = {4{1'b1}} | 32'h0;
    assign b_hexn  = {4{8'hFF}};
  end
endmodule
