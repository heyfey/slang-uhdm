// r10earl104 g5 -- WHERE THE READ LIVES.
// MEASUREMENT ONLY.  g4 reproduced earl55's a4 and showed that a MODULE-LEVEL
// cont-assign / if-generate condition / select-shaped override actual flips the
// folded replication constant's typespec from golden's minted int_typespec to
// the parameter's DECLARED one -- INCLUDING the `$bits(x)'({X,...})` size cast
// that earl55 recorded as `unreduced`.  But pinmux.sv:176 -- the head's own
// reader -- is INSIDE `for (genvar k...) begin : gen_mio_out`, and golden keeps
// int there.  This arm crosses WHERE the read lives (module body / for-generate /
// if-generate / bare generate block / a child module) against widths {4, 32}.
module g5_gscope104(input logic ext);
  m_d1_4 u_d1_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d2_4 u_d2_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d3_4 u_d3_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d4_4 u_d4_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d5_4 u_d5_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d6_4 u_d6_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d7_4 u_d7_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d8_4 u_d8_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d9_4 u_d9_4 (.o(), .o2(), .oo(), .ext(ext));
  m_da_4 u_da_4 (.o(), .o2(), .oo(), .ext(ext));
  m_d1_32 u_d1_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d2_32 u_d2_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d3_32 u_d3_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d4_32 u_d4_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d5_32 u_d5_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d6_32 u_d6_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d7_32 u_d7_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d8_32 u_d8_32 (.o(), .o2(), .oo(), .ext(ext));
  m_d9_32 u_d9_32 (.o(), .o2(), .oo(), .ext(ext));
  m_da_32 u_da_32 (.o(), .o2(), .oo(), .ext(ext));
endmodule

module kk104 #(parameter P = 0) (output logic z); assign z = |P; endmodule

module m_d1_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // a cont-assign READ inside a FOR-GENERATE scope
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = |X;
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d2_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // a bit-select read inside a FOR-GENERATE scope
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = X[0];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d3_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // an IF-GENERATE CONDITION inside a FOR-GENERATE scope -- the DioPeriphHasSleepMode shape
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    if (X[k]) begin : t assign oo[k] = 1'b1; end else begin : f assign oo[k] = 1'b0; end
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d4_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // the EXACT pinmux.sv:176 shape -- a SIZE CAST over a concat, inside a FOR-GENERATE scope
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    logic [W+2:0] mux;
    assign mux = $bits(mux)'({X, 1'b1, 1'b1, 1'b1});
    assign oo[k] = mux[0];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d5_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // a cont-assign READ inside an IF-GENERATE scope
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  if (1) begin : g
    assign oo[0] = |X;
  end
  assign oo[1] = 1'b0;
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d6_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // a cont-assign READ inside a NAMED generate BLOCK (no condition, no loop)
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  generate begin : g
    assign oo[0] = |X;
  end endgenerate
  assign oo[1] = 1'b0;
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d7_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // the read is in a CHILD MODULE, through a whole-param override actual
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  kk104 #(.P(W)) u_kk (.z(oo[0]));
  assign oo[1] = 1'b0;
  assign o2 = X;
  assign o = ext;
endmodule

module m_d8_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // BOTH: a module-level read AND a for-generate read
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o = |X;
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = X[0];
  end
  assign o2 = '0;
endmodule

module m_d9_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // ONLY a for-generate read, and the loop bound is the param itself
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = X[k];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_da_4 (output logic o, output logic [4-1:0] o2, output logic [1:0] oo, input logic ext);
  // a read inside an ALWAYS_COMB that is itself inside a FOR-GENERATE scope
  localparam int W = 4;
  localparam logic [4-1:0] X = {4{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    always_comb oo[k] = X[0];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d1_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // a cont-assign READ inside a FOR-GENERATE scope
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = |X;
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d2_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // a bit-select read inside a FOR-GENERATE scope
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = X[0];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d3_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // an IF-GENERATE CONDITION inside a FOR-GENERATE scope -- the DioPeriphHasSleepMode shape
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    if (X[k]) begin : t assign oo[k] = 1'b1; end else begin : f assign oo[k] = 1'b0; end
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d4_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // the EXACT pinmux.sv:176 shape -- a SIZE CAST over a concat, inside a FOR-GENERATE scope
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    logic [W+2:0] mux;
    assign mux = $bits(mux)'({X, 1'b1, 1'b1, 1'b1});
    assign oo[k] = mux[0];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d5_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // a cont-assign READ inside an IF-GENERATE scope
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  if (1) begin : g
    assign oo[0] = |X;
  end
  assign oo[1] = 1'b0;
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d6_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // a cont-assign READ inside a NAMED generate BLOCK (no condition, no loop)
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  generate begin : g
    assign oo[0] = |X;
  end endgenerate
  assign oo[1] = 1'b0;
  assign o2 = '0;
  assign o = ext;
endmodule

module m_d7_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // the read is in a CHILD MODULE, through a whole-param override actual
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  kk104 #(.P(W)) u_kk (.z(oo[0]));
  assign oo[1] = 1'b0;
  assign o2 = X;
  assign o = ext;
endmodule

module m_d8_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // BOTH: a module-level read AND a for-generate read
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o = |X;
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = X[0];
  end
  assign o2 = '0;
endmodule

module m_d9_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // ONLY a for-generate read, and the loop bound is the param itself
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    assign oo[k] = X[k];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

module m_da_32 (output logic o, output logic [32-1:0] o2, output logic [1:0] oo, input logic ext);
  // a read inside an ALWAYS_COMB that is itself inside a FOR-GENERATE scope
  localparam int W = 32;
  localparam logic [32-1:0] X = {32{1'b1}};
  for (genvar k = 0; k < 2; k++) begin : g
    always_comb oo[k] = X[0];
  end
  assign o2 = '0;
  assign o = ext;
endmodule

