// r10earl104 g4 -- THE CONSUMER CROSS PRODUCT at width > 1.
// MEASUREMENT ONLY.  earl55's a4 crossed 11 consumers x widths {1,4,15} and
// found that at width 1 golden ALWAYS mints int_typespec while at width > 1 the
// CONSUMER decides.  This arm re-derives that column on THIS base and ADDS the
// four forms a4 did not have: the SIZE CAST over a concat (cb), the EXACT
// pinmux.sv:176 shape (cc), a read that only reaches $bits() (cd), and a read
// through a function-call argument (ce) -- plus width 32, the head's own width.
// Every module is instantiated exactly ONCE; ELAB view is where the head lives.
module g4_cons104(input logic ext);
  m_c0_4 u_c0_4 (.o(), .o2(), .ext(ext));
  m_c1_4 u_c1_4 (.o(), .o2(), .ext(ext));
  m_c2_4 u_c2_4 (.o(), .o2(), .ext(ext));
  m_c3_4 u_c3_4 (.o(), .o2(), .ext(ext));
  m_c4_4 u_c4_4 (.o(), .o2(), .ext(ext));
  m_c5_4 u_c5_4 (.o(), .o2(), .ext(ext));
  m_c6_4 u_c6_4 (.o(), .o2(), .ext(ext));
  m_c7_4 u_c7_4 (.o(), .o2(), .ext(ext));
  m_c8_4 u_c8_4 (.o(), .o2(), .ext(ext));
  m_c9_4 u_c9_4 (.o(), .o2(), .ext(ext));
  m_ca_4 u_ca_4 (.o(), .o2(), .ext(ext));
  m_cb_4 u_cb_4 (.o(), .o2(), .ext(ext));
  m_cc_4 u_cc_4 (.o(), .o2(), .ext(ext));
  m_cd_4 u_cd_4 (.o(), .o2(), .ext(ext));
  m_ce_4 u_ce_4 (.o(), .o2(), .ext(ext));
  m_c0_32 u_c0_32 (.o(), .o2(), .ext(ext));
  m_c1_32 u_c1_32 (.o(), .o2(), .ext(ext));
  m_c2_32 u_c2_32 (.o(), .o2(), .ext(ext));
  m_c3_32 u_c3_32 (.o(), .o2(), .ext(ext));
  m_c4_32 u_c4_32 (.o(), .o2(), .ext(ext));
  m_c5_32 u_c5_32 (.o(), .o2(), .ext(ext));
  m_c6_32 u_c6_32 (.o(), .o2(), .ext(ext));
  m_c7_32 u_c7_32 (.o(), .o2(), .ext(ext));
  m_c8_32 u_c8_32 (.o(), .o2(), .ext(ext));
  m_c9_32 u_c9_32 (.o(), .o2(), .ext(ext));
  m_ca_32 u_ca_32 (.o(), .o2(), .ext(ext));
  m_cb_32 u_cb_32 (.o(), .o2(), .ext(ext));
  m_cc_32 u_cc_32 (.o(), .o2(), .ext(ext));
  m_cd_32 u_cd_32 (.o(), .o2(), .ext(ext));
  m_ce_32 u_ce_32 (.o(), .o2(), .ext(ext));
endmodule

module k104 #(parameter P = 0) (output logic z); assign z = |P; endmodule
function automatic logic f104(input logic a); return ~a; endfunction

module m_c0_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // no use at all
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  assign o = 1'b0;
endmodule

module m_c1_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select ALONE as a cont-assign RHS
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  assign o = X[0];
endmodule

module m_c2_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select inside a NON-CONSTANT operation
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  assign o = X[0] ^ ext;
endmodule

module m_c3_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // the WHOLE param ALONE as a cont-assign RHS
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = X;
  assign o = ext;
endmodule

module m_c4_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // the whole param inside a CONCAT
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = {X};
  assign o = ext;
endmodule

module m_c5_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select as an IF-GENERATE condition
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  if (X[0]) begin : g_t assign o = 1'b1; end else begin : g_f assign o = 1'b0; end
endmodule

module m_c6_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // the WHOLE param as a parameter-override actual
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  k104 #(.P(X)) u_k (.z(o));
endmodule

module m_c7_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select as a parameter-override actual
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  k104 #(.P(X[0])) u_k (.z(o));
endmodule

module m_c8_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select read in an ALWAYS_COMB
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  always_comb o = X[0];
endmodule

module m_c9_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a REDUCTION of the whole param
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  assign o = |X;
endmodule

module m_ca_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select as a PROCEDURAL if condition
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  always_comb begin if (X[0]) o = 1'b1; else o = 1'b0; end
endmodule

module m_cb_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // A SIZE CAST over a concat of the param -- the pinmux.sv:176 shape
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = $bits(o2)'({X});
  assign o = ext;
endmodule

module m_cc_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // the EXACT pinmux.sv:176 shape: a size cast over {X, 1'b1, 1'b1, 1'b1}
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = $bits(o2)'({X, 1'b1, 1'b1, 1'b1});
  assign o = ext;
endmodule

module m_cd_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // the param read inside a $bits() ARGUMENT only
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  assign o = ext ^ (|$bits(X));
endmodule

module m_ce_4 (output logic o, output logic [4-1:0] o2, input logic ext);
  // a bit-select read by a FUNCTION call argument in a cont-assign
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = '0;
  assign o = f104(X[0]) ^ ext;
endmodule

module m_c0_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // no use at all
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  assign o = 1'b0;
endmodule

module m_c1_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select ALONE as a cont-assign RHS
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  assign o = X[0];
endmodule

module m_c2_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select inside a NON-CONSTANT operation
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  assign o = X[0] ^ ext;
endmodule

module m_c3_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // the WHOLE param ALONE as a cont-assign RHS
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = X;
  assign o = ext;
endmodule

module m_c4_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // the whole param inside a CONCAT
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = {X};
  assign o = ext;
endmodule

module m_c5_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select as an IF-GENERATE condition
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  if (X[0]) begin : g_t assign o = 1'b1; end else begin : g_f assign o = 1'b0; end
endmodule

module m_c6_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // the WHOLE param as a parameter-override actual
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  k104 #(.P(X)) u_k (.z(o));
endmodule

module m_c7_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select as a parameter-override actual
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  k104 #(.P(X[0])) u_k (.z(o));
endmodule

module m_c8_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select read in an ALWAYS_COMB
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  always_comb o = X[0];
endmodule

module m_c9_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a REDUCTION of the whole param
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  assign o = |X;
endmodule

module m_ca_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select as a PROCEDURAL if condition
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  always_comb begin if (X[0]) o = 1'b1; else o = 1'b0; end
endmodule

module m_cb_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // A SIZE CAST over a concat of the param -- the pinmux.sv:176 shape
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = $bits(o2)'({X});
  assign o = ext;
endmodule

module m_cc_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // the EXACT pinmux.sv:176 shape: a size cast over {X, 1'b1, 1'b1, 1'b1}
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = $bits(o2)'({X, 1'b1, 1'b1, 1'b1});
  assign o = ext;
endmodule

module m_cd_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // the param read inside a $bits() ARGUMENT only
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  assign o = ext ^ (|$bits(X));
endmodule

module m_ce_32 (output logic o, output logic [32-1:0] o2, input logic ext);
  // a bit-select read by a FUNCTION call argument in a cont-assign
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o2 = '0;
  assign o = f104(X[0]) ^ ext;
endmodule

