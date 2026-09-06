// r10v104 va5 -- edge positions for the corrected discriminator.
module m_e1 (output logic o);      // select ONLY in an UNINSTANTIATED generate branch's range
  localparam logic [4-1:0] X = {4{1'b1}};
  if (0) begin : gs logic [X[0]:0] w; assign w = '0; end
  assign o = 1'b0;
endmodule
module m_e2 (input logic clk, output logic o);  // select in a CONCURRENT assertion
  localparam logic [4-1:0] X = {4{1'b1}};
  a2: assert property (@(posedge clk) X[0] == 1'b1);
  assign o = 1'b0;
endmodule
module m_e3 (output logic o);      // select in a PART-SELECT range of a net decl
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [7:0] w; assign w = '0;
  assign o = w[X[0]];
endmodule
module m_e4 (output logic o);      // select only inside a FUNCTION body's expression
  localparam logic [4-1:0] X = {4{1'b1}};
  function automatic logic g4(); return X[0]; endfunction
  assign o = g4();
endmodule
module va5_edge104(input logic clk, output logic o);
  logic [3:0] q;
  m_e1 u_e1(.o(q[0])); m_e2 u_e2(.clk(clk), .o(q[1])); m_e3 u_e3(.o(q[2])); m_e4 u_e4(.o(q[3]));
  assign o = |q;
endmodule
