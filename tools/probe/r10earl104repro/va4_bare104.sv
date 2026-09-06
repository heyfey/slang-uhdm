// r10v104 va4 -- BARE (non-select) reads in the positions that flip.
module m_b1 (output logic o);     // net range, BARE reduction
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [(|X):0] w; assign w = '0; assign o = w[0];
endmodule
module m_b2 (output logic o);     // genfor bound, BARE reduction
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] oo;
  for (genvar i = 0; i < (|X)+1; i = i + 1) begin : g assign oo[i] = 1'b0; end
  assign o = oo[0];
endmodule
module m_b3 (output logic o);     // net range, WHOLE name in an arithmetic fold
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [X-14:0] w; assign w = '0; assign o = w[0];
endmodule
module m_b4 (output logic o);     // gen-scope localparam, BARE reduction read
  localparam logic [4-1:0] X = {4{1'b1}};
  if (1) begin : gs localparam int Y = |X; logic w; assign w = Y[0]; end
  assign o = gs.w;
endmodule
module va4_bare104(output logic o);
  logic [3:0] q;
  m_b1 u_b1(.o(q[0])); m_b2 u_b2(.o(q[1])); m_b3 u_b3(.o(q[2])); m_b4 u_b4(.o(q[3]));
  assign o = |q;
endmodule
