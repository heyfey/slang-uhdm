// r10earl104 g7 -- THE POSITIVE READ ENUMERATION's remaining cells.
// MEASUREMENT ONLY.  One module per read POSITION; every module holds exactly
// one `localparam logic [3:0] X = {4{1'b1}}` and exactly ONE read of it, so the
// golden typespec of X's folded Rhs constant names that position and nothing
// else.  Golden `int_typespec@LOCLESS UINT:1` = the mint SURVIVES (a cell the
// law may win); golden `logic_typespec[3:0]` = the read TOOK IT AWAY (a cell
// the law must not touch).
module subg7 #(parameter P = 0) (output logic z); assign z = |P; endmodule

// k1 -- BARE name as a generate-IF condition
module m_k1 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  if (X) begin : t assign o = 1'b1; end else begin : f assign o = 1'b0; end
endmodule

// k2 -- BARE name as a generate-CASE condition
module m_k2 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  case (X)
    4'hF: begin : ca assign o = 1'b1; end
    default: begin : cb assign o = 1'b0; end
  endcase
endmodule

// k3 -- BARE name as a generate-CASE ITEM LABEL
module m_k3 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  localparam logic [3:0] SEL = 4'hF;
  case (SEL)
    X: begin : ca assign o = 1'b1; end
    default: begin : cb assign o = 1'b0; end
  endcase
endmodule

// k4 -- BARE whole name as a NET's declared range bound
module m_k4 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [X:0] w4; assign w4 = '0;
  assign o = w4[0];
endmodule

// k5 -- BARE whole name in an INSTANCE ARRAY's range
module m_k5 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [15:0] zz;
  subg7 #(.P(2)) u_e [X:0] (.z(zz));
  assign o = zz[0];
endmodule

// k6 -- the read reaches only $bits(X), module-level cont-assign
module m_k6 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [7:0] w6; assign w6 = $bits(X);
  assign o = w6[0];
endmodule

// k7 -- BARE parameter-override actual
module m_k7 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  subg7 #(.P(X)) u7 (.z(o));
endmodule

// k8 -- SELECT inside a generate-FOR body's net declared range
module m_k8 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] q8;
  for (genvar i = 0; i < 2; i = i + 1) begin : g
    logic [X[0]:0] w; assign w = '0; assign q8[i] = w[0];
  end
  assign o = q8[0];
endmodule

// k9 -- SELECT inside a PROCEDURAL block's own variable declaration range
module m_k9 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] w9;
  always_comb begin
    automatic logic [X[0]:0] lv = '0;
    w9 = {1'b0, lv[0]};
  end
  assign o = w9[0];
endmodule

// ka -- BARE name in a CONCURRENT ASSERTION
module m_ka (input logic clk, output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  aa: assert property (@(posedge clk) X == 4'hF);
  assign o = 1'b0;
endmodule

// kb -- SELECT in a PACKED STRUCT member range inside a generate scope
module m_kb (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  if (1) begin : gs
    typedef struct packed { logic [X[0]:0] f; } st_t;
    st_t s; assign s = '0; assign o = s.f[0];
  end
endmodule

// kc -- SELECT ONLY inside a TASK body
module m_kc (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] wc;
  task automatic tk(output logic a); a = X[0]; endtask
  always_comb begin logic r; tk(r); wc = {1'b0, r}; end
  assign o = wc[0];
endmodule

// kd -- SELECT in the parameter's OWN declared range (self-reference is
//       impossible; this is a SECOND parameter's range reading the first)
module m_kd (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  localparam logic [1:0] Y = 2'b11;
  logic [Y[0]:0] wd; assign wd = '0;
  assign o = wd[0] ^ X[0];
endmodule

// ke -- NO read at all (the positive control for this arm)
module m_ke (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] we; assign we = '0;
  assign o = we[0];
endmodule

module g7_pos104(input logic clk, output logic o);
  logic [13:0] q;
  m_k1 u_k1(.o(q[0]));   m_k2 u_k2(.o(q[1]));   m_k3 u_k3(.o(q[2]));
  m_k4 u_k4(.o(q[3]));   m_k5 u_k5(.o(q[4]));   m_k6 u_k6(.o(q[5]));
  m_k7 u_k7(.o(q[6]));   m_k8 u_k8(.o(q[7]));   m_k9 u_k9(.o(q[8]));
  m_ka u_ka(.clk(clk), .o(q[9]));
  m_kb u_kb(.o(q[10]));  m_kc u_kc(.o(q[11]));  m_kd u_kd(.o(q[12]));
  m_ke u_ke(.o(q[13]));
  assign o = |q;
endmodule
