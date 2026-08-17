// r10earl55 a4 — THE FULL CROSS PRODUCT.  a1/a2/a3 refuted width, count
// origin, declaration order, instance count and 'a port shares the type';
// what survived every arm is that the CONSUMER of the parameter decides.
// a4 crosses width x consumer so the rule is read off a table instead of
// inferred from three coincidences.  ELAB view; every module instantiated once.
module a4_earl55(input logic ext);
  m_c0_1 u_c0_1 (.o(), .ext(ext));
  m_c1_1 u_c1_1 (.o(), .ext(ext));
  m_c2_1 u_c2_1 (.o(), .ext(ext));
  m_c3_1 u_c3_1 (.o(), .ext(ext), .o2());
  m_c4_1 u_c4_1 (.o(), .ext(ext), .o2());
  m_c5_1 u_c5_1 (.o(), .ext(ext));
  m_c6_1 u_c6_1 (.o(), .ext(ext));
  m_c7_1 u_c7_1 (.o(), .ext(ext));
  m_c8_1 u_c8_1 (.o(), .ext(ext));
  m_c9_1 u_c9_1 (.o(), .ext(ext));
  m_ca_1 u_ca_1 (.o(), .ext(ext));
  m_c0_4 u_c0_4 (.o(), .ext(ext));
  m_c1_4 u_c1_4 (.o(), .ext(ext));
  m_c2_4 u_c2_4 (.o(), .ext(ext));
  m_c3_4 u_c3_4 (.o(), .ext(ext), .o2());
  m_c4_4 u_c4_4 (.o(), .ext(ext), .o2());
  m_c5_4 u_c5_4 (.o(), .ext(ext));
  m_c6_4 u_c6_4 (.o(), .ext(ext));
  m_c7_4 u_c7_4 (.o(), .ext(ext));
  m_c8_4 u_c8_4 (.o(), .ext(ext));
  m_c9_4 u_c9_4 (.o(), .ext(ext));
  m_ca_4 u_ca_4 (.o(), .ext(ext));
  m_c0_15 u_c0_15 (.o(), .ext(ext));
  m_c1_15 u_c1_15 (.o(), .ext(ext));
  m_c2_15 u_c2_15 (.o(), .ext(ext));
  m_c3_15 u_c3_15 (.o(), .ext(ext), .o2());
  m_c4_15 u_c4_15 (.o(), .ext(ext), .o2());
  m_c5_15 u_c5_15 (.o(), .ext(ext));
  m_c6_15 u_c6_15 (.o(), .ext(ext));
  m_c7_15 u_c7_15 (.o(), .ext(ext));
  m_c8_15 u_c8_15 (.o(), .ext(ext));
  m_c9_15 u_c9_15 (.o(), .ext(ext));
  m_ca_15 u_ca_15 (.o(), .ext(ext));
endmodule

module k55 #(parameter P = 0) (output logic z); assign z = |P; endmodule

module m_c0_1 (output logic o, input logic ext);
  // no use at all
  localparam logic [1-1:0] X = {1{1'b1}};
  assign o = 1'b0;
endmodule

module m_c1_1 (output logic o, input logic ext);
  // bit-select ALONE as a cont-assign RHS
  localparam logic [1-1:0] X = {1{1'b1}};
  assign o = X[0];
endmodule

module m_c2_1 (output logic o, input logic ext);
  // bit-select inside an OPERATION
  localparam logic [1-1:0] X = {1{1'b1}};
  assign o = X[0] ^ ext;
endmodule

module m_c3_1 (output logic o, input logic ext, output logic [1-1:0] o2);
  // the WHOLE param ALONE as a cont-assign RHS
  localparam logic [1-1:0] X = {1{1'b1}};
  assign o2 = X;
  assign o = ext;
endmodule

module m_c4_1 (output logic o, input logic ext, output logic [1-1:0] o2);
  // the whole param inside a CONCAT
  localparam logic [1-1:0] X = {1{1'b1}};
  assign o2 = {X};
  assign o = ext;
endmodule

module m_c5_1 (output logic o, input logic ext);
  // bit-select as an IF-GENERATE condition
  localparam logic [1-1:0] X = {1{1'b1}};
  if (X[0]) begin : g_t assign o = 1'b1; end else begin : g_f assign o = 1'b0; end
endmodule

module m_c6_1 (output logic o, input logic ext);
  // the WHOLE param as a parameter-override actual
  localparam logic [1-1:0] X = {1{1'b1}};
  k55 #(.P(X)) u_k (.z(o));
endmodule

module m_c7_1 (output logic o, input logic ext);
  // a bit-select as a parameter-override actual
  localparam logic [1-1:0] X = {1{1'b1}};
  k55 #(.P(X[0])) u_k (.z(o));
endmodule

module m_c8_1 (output logic o, input logic ext);
  // bit-select read in an ALWAYS_COMB
  localparam logic [1-1:0] X = {1{1'b1}};
  always_comb o = X[0];
endmodule

module m_c9_1 (output logic o, input logic ext);
  // a REDUCTION of the whole param
  localparam logic [1-1:0] X = {1{1'b1}};
  assign o = |X;
endmodule

module m_ca_1 (output logic o, input logic ext);
  // bit-select as a PROCEDURAL if condition
  localparam logic [1-1:0] X = {1{1'b1}};
  always_comb begin if (X[0]) o = 1'b1; else o = 1'b0; end
endmodule

module m_c0_4 (output logic o, input logic ext);
  // no use at all
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o = 1'b0;
endmodule

module m_c1_4 (output logic o, input logic ext);
  // bit-select ALONE as a cont-assign RHS
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o = X[0];
endmodule

module m_c2_4 (output logic o, input logic ext);
  // bit-select inside an OPERATION
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o = X[0] ^ ext;
endmodule

module m_c3_4 (output logic o, input logic ext, output logic [4-1:0] o2);
  // the WHOLE param ALONE as a cont-assign RHS
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = X;
  assign o = ext;
endmodule

module m_c4_4 (output logic o, input logic ext, output logic [4-1:0] o2);
  // the whole param inside a CONCAT
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o2 = {X};
  assign o = ext;
endmodule

module m_c5_4 (output logic o, input logic ext);
  // bit-select as an IF-GENERATE condition
  localparam logic [4-1:0] X = {4{1'b1}};
  if (X[0]) begin : g_t assign o = 1'b1; end else begin : g_f assign o = 1'b0; end
endmodule

module m_c6_4 (output logic o, input logic ext);
  // the WHOLE param as a parameter-override actual
  localparam logic [4-1:0] X = {4{1'b1}};
  k55 #(.P(X)) u_k (.z(o));
endmodule

module m_c7_4 (output logic o, input logic ext);
  // a bit-select as a parameter-override actual
  localparam logic [4-1:0] X = {4{1'b1}};
  k55 #(.P(X[0])) u_k (.z(o));
endmodule

module m_c8_4 (output logic o, input logic ext);
  // bit-select read in an ALWAYS_COMB
  localparam logic [4-1:0] X = {4{1'b1}};
  always_comb o = X[0];
endmodule

module m_c9_4 (output logic o, input logic ext);
  // a REDUCTION of the whole param
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o = |X;
endmodule

module m_ca_4 (output logic o, input logic ext);
  // bit-select as a PROCEDURAL if condition
  localparam logic [4-1:0] X = {4{1'b1}};
  always_comb begin if (X[0]) o = 1'b1; else o = 1'b0; end
endmodule

module m_c0_15 (output logic o, input logic ext);
  // no use at all
  localparam logic [15-1:0] X = {15{1'b1}};
  assign o = 1'b0;
endmodule

module m_c1_15 (output logic o, input logic ext);
  // bit-select ALONE as a cont-assign RHS
  localparam logic [15-1:0] X = {15{1'b1}};
  assign o = X[0];
endmodule

module m_c2_15 (output logic o, input logic ext);
  // bit-select inside an OPERATION
  localparam logic [15-1:0] X = {15{1'b1}};
  assign o = X[0] ^ ext;
endmodule

module m_c3_15 (output logic o, input logic ext, output logic [15-1:0] o2);
  // the WHOLE param ALONE as a cont-assign RHS
  localparam logic [15-1:0] X = {15{1'b1}};
  assign o2 = X;
  assign o = ext;
endmodule

module m_c4_15 (output logic o, input logic ext, output logic [15-1:0] o2);
  // the whole param inside a CONCAT
  localparam logic [15-1:0] X = {15{1'b1}};
  assign o2 = {X};
  assign o = ext;
endmodule

module m_c5_15 (output logic o, input logic ext);
  // bit-select as an IF-GENERATE condition
  localparam logic [15-1:0] X = {15{1'b1}};
  if (X[0]) begin : g_t assign o = 1'b1; end else begin : g_f assign o = 1'b0; end
endmodule

module m_c6_15 (output logic o, input logic ext);
  // the WHOLE param as a parameter-override actual
  localparam logic [15-1:0] X = {15{1'b1}};
  k55 #(.P(X)) u_k (.z(o));
endmodule

module m_c7_15 (output logic o, input logic ext);
  // a bit-select as a parameter-override actual
  localparam logic [15-1:0] X = {15{1'b1}};
  k55 #(.P(X[0])) u_k (.z(o));
endmodule

module m_c8_15 (output logic o, input logic ext);
  // bit-select read in an ALWAYS_COMB
  localparam logic [15-1:0] X = {15{1'b1}};
  always_comb o = X[0];
endmodule

module m_c9_15 (output logic o, input logic ext);
  // a REDUCTION of the whole param
  localparam logic [15-1:0] X = {15{1'b1}};
  assign o = |X;
endmodule

module m_ca_15 (output logic o, input logic ext);
  // bit-select as a PROCEDURAL if condition
  localparam logic [15-1:0] X = {15{1'b1}};
  always_comb begin if (X[0]) o = 1'b1; else o = 1'b0; end
endmodule
