// r10v104 va1 -- READER POSITIONS NEITHER SCAN ENTERS.  MEASUREMENT ONLY.

module sub104 #(parameter P = 0) (output logic z); assign z = |P; endmodule

module va1_read104(input logic ext);
  m_r1_4 u_r1_4 (.o(), .ext(ext));
  m_r1_32 u_r1_32 (.o(), .ext(ext));
  m_r2_4 u_r2_4 (.o(), .ext(ext));
  m_r2_32 u_r2_32 (.o(), .ext(ext));
  m_r3_4 u_r3_4 (.o(), .ext(ext));
  m_r3_32 u_r3_32 (.o(), .ext(ext));
  m_r4_4 u_r4_4 (.o(), .ext(ext));
  m_r4_32 u_r4_32 (.o(), .ext(ext));
  m_r5_4 u_r5_4 (.o(), .ext(ext));
  m_r5_32 u_r5_32 (.o(), .ext(ext));
  m_r7_4 u_r7_4 (.o(), .ext(ext));
  m_r7_32 u_r7_32 (.o(), .ext(ext));
  m_r8_4 u_r8_4 (.o(), .ext(ext));
  m_r8_32 u_r8_32 (.o(), .ext(ext));
  m_r9_4 u_r9_4 (.o(), .ext(ext));
  m_r9_32 u_r9_32 (.o(), .ext(ext));
  m_ra_4 u_ra_4 (.o(), .ext(ext));
  m_ra_32 u_ra_32 (.o(), .ext(ext));
  m_rb_4 u_rb_4 (.o(), .ext(ext));
  m_rb_32 u_rb_32 (.o(), .ext(ext));
  m_rc_4 u_rc_4 (.o(), .ext(ext));
  m_rc_32 u_rc_32 (.o(), .ext(ext));
  m_rd_4 u_rd_4 (.o(), .ext(ext));
  m_rd_32 u_rd_32 (.o(), .ext(ext));
  m_re_4 u_re_4 (.o(), .ext(ext));
  m_re_32 u_re_32 (.o(), .ext(ext));
endmodule

// r1 w4 -- another PARAMETER's initializer, SELECT
module m_r1_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  localparam int Y = X[0];
  assign o = 1'b0;
endmodule

// r1 w32 -- another PARAMETER's initializer, SELECT
module m_r1_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  localparam int Y = X[0];
  assign o = 1'b0;
endmodule

// r2 w4 -- another PARAMETER's initializer, BARE reduction
module m_r2_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  localparam int Y = |X;
  assign o = 1'b0;
endmodule

// r2 w32 -- another PARAMETER's initializer, BARE reduction
module m_r2_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  localparam int Y = |X;
  assign o = 1'b0;
endmodule

// r3 w4 -- another PARAMETER's initializer, $clog2 (needs the VALUE)
module m_r3_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  localparam int Y = $clog2(X);
  assign o = 1'b0;
endmodule

// r3 w32 -- another PARAMETER's initializer, $clog2 (needs the VALUE)
module m_r3_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  localparam int Y = $clog2(X);
  assign o = 1'b0;
endmodule

// r4 w4 -- GENERATE-FOR loop BOUND
module m_r4_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] oo;
  for (genvar i = 0; i < X[0]+1; i = i + 1) begin : gl
    assign oo[i] = 1'b0;
  end
  assign o = 1'b0;
endmodule

// r4 w32 -- GENERATE-FOR loop BOUND
module m_r4_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] oo;
  for (genvar i = 0; i < X[0]+1; i = i + 1) begin : gl
    assign oo[i] = 1'b0;
  end
  assign o = 1'b0;
endmodule

// r5 w4 -- a NET's declared RANGE
module m_r5_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [X[0]:0] w5;
  assign w5 = '0;
  assign o = 1'b0;
endmodule

// r5 w32 -- a NET's declared RANGE
module m_r5_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [X[0]:0] w5;
  assign w5 = '0;
  assign o = 1'b0;
endmodule

// r7 w4 -- control: no read at all (r7 pair for defparam arm)
module m_r7_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] w7;
  assign w7 = '0;
  assign o = 1'b0;
endmodule

// r7 w32 -- control: no read at all (r7 pair for defparam arm)
module m_r7_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] w7;
  assign w7 = '0;
  assign o = 1'b0;
endmodule

// r8 w4 -- a TYPEDEF's declared RANGE
module m_r8_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  typedef logic [X[0]:0] t8;
  t8 w8;
  assign w8 = '0;
  assign o = 1'b0;
endmodule

// r8 w32 -- a TYPEDEF's declared RANGE
module m_r8_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  typedef logic [X[0]:0] t8;
  t8 w8;
  assign w8 = '0;
  assign o = 1'b0;
endmodule

// r9 w4 -- control: PROCEDURAL read (expected: keeps the mint)
module m_r9_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] w9;
  always_comb w9 = {1'b0, X[0]};
  assign o = 1'b0;
endmodule

// r9 w32 -- control: PROCEDURAL read (expected: keeps the mint)
module m_r9_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] w9;
  always_comb w9 = {1'b0, X[0]};
  assign o = 1'b0;
endmodule

// ra w4 -- control: GENERATE-CASE item (the new scan)
module m_ra_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] wa;
  assign wa = '0;
  case (X[0])
    1'b1: begin : ga assign o = 1'b1; end
    default: begin : gb assign o = 1'b0; end
  endcase
endmodule

// ra w32 -- control: GENERATE-CASE item (the new scan)
module m_ra_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] wa;
  assign wa = '0;
  case (X[0])
    1'b1: begin : ga assign o = 1'b1; end
    default: begin : gb assign o = 1'b0; end
  endcase
endmodule

// rb w4 -- control: NO read of X at all (expected: keeps the mint)
module m_rb_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] wb;
  assign wb = '0;
  localparam int Yb = 3;
  assign o = 1'b0;
endmodule

// rb w32 -- control: NO read of X at all (expected: keeps the mint)
module m_rb_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] wb;
  assign wb = '0;
  localparam int Yb = 3;
  assign o = 1'b0;
endmodule

// rc w4 -- a NET's declared RANGE inside an expression
module m_rc_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [X[0]+1:0] wc;
  assign wc = '0;
  assign o = 1'b0;
endmodule

// rc w32 -- a NET's declared RANGE inside an expression
module m_rc_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [X[0]+1:0] wc;
  assign wc = '0;
  assign o = 1'b0;
endmodule

// rd w4 -- control: INITIAL block read (procedural)
module m_rd_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] wd;
  assign wd = '0;
  initial begin if (X[0]) $display("x"); end
  assign o = 1'b0;
endmodule

// rd w32 -- control: INITIAL block read (procedural)
module m_rd_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] wd;
  assign wd = '0;
  initial begin if (X[0]) $display("x"); end
  assign o = 1'b0;
endmodule

// re w4 -- an INSTANCE ARRAY's range
module m_re_4 (output logic o, input logic ext);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] we;
  assign we = '0;
  sub104 #(.P(2)) u_e [X[0]:0] (.z());
  assign o = 1'b0;
endmodule

// re w32 -- an INSTANCE ARRAY's range
module m_re_32 (output logic o, input logic ext);
  localparam logic [32-1:0] X = {32{1'b1}};
  logic [1:0] we;
  assign we = '0;
  sub104 #(.P(2)) u_e [X[0]:0] (.z());
  assign o = 1'b0;
endmodule
