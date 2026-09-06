// r10v104 w4 -- READ POSITIONS the syntax enumeration and the AST scans may
// both miss, plus the excluded-context faces.  MEASUREMENT ONLY.
module subw4 #(parameter int P = 0) (output logic z); assign z = |P; endmodule

// q2 -- select ONLY as ANOTHER select's INDEX, in a net range
module m_q2 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  localparam logic [7:0] Y = 8'h0f;
  logic [Y[X[0]]:0] w; assign w = '0;
  assign o = w[0];
endmodule

// q3 -- select inside a CLASS PROPERTY declaration's range (class in a module)
module m_q3 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  class Cq3; logic [X[0]:0] p; endclass
  assign o = 1'b0;
endmodule

// q4 -- select inside a CLASS METHOD body only
module m_q4 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  class Cq4; function bit f(); return X[0]; endfunction endclass
  assign o = 1'b0;
endmodule

// q5 -- select inside a FINAL block only
module m_q5 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic r; initial r = 1'b0;
  final begin r = X[0]; end
  assign o = 1'b0;
endmodule

// q6 -- select split across TWO generate arms: BARE in the taken arm,
//        SELECT in the untaken one
module m_q6 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic wa, wb;
  if (1) begin : gq6a assign wa = |X; end else begin : gq6b assign wa = X[0]; end
  assign wb = 1'b0;
  assign o = 1'b0;
endmodule

// q7 -- $bits ONLY, inside a GENERATE SCOPE
module m_q7 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic [7:0] w7;
  for (genvar g = 0; g < 1; g++) begin : gq7 assign w7 = $bits(X); end
  assign o = 1'b0;
endmodule

// q8 -- THREE reads of one parameter: bare gen-scope, select-in-function,
//        select-in-always  (none of them enumerated)
module m_q8 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic w8a, w8b;
  for (genvar g = 0; g < 1; g++) begin : gq8 assign w8a = |X; end
  function automatic bit fq8(); return X[0]; endfunction
  always_comb w8b = X[1];
  assign o = 1'b0;
endmodule

// q9 -- select inside a SPECIFY-adjacent construct: a covergroup
module m_q9 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic clk; assign clk = 1'b0;
  covergroup cg9 @(posedge clk); cp : coverpoint X[0]; endgroup
  assign o = 1'b0;
endmodule

// qa -- select inside a PROPERTY declaration only
module m_qa (input logic clk, output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  property pqa; @(posedge clk) X[0]; endproperty
  assign o = 1'b0;
endmodule

// qb -- select in a NET RANGE of a module-level net, width 32 (head-shaped)
module m_qb (output logic o);
  localparam logic [31:0] X = {32{1'b1}};
  logic [X[0]:0] w; assign w = '0;
  assign o = w[0];
endmodule

// qc -- NO read at all, width 32 (head-shaped control: must MINT)
module m_qc (output logic o);
  localparam logic [31:0] X = {32{1'b1}};
  assign o = 1'b0;
endmodule

module w4_pos104 (input logic clk, input logic ext, output logic o);
  m_q2 u_q2(.o()); m_q3 u_q3(.o()); m_q4 u_q4(.o());
  m_q5 u_q5(.o()); m_q6 u_q6(.o()); m_q7 u_q7(.o()); m_q8 u_q8(.o());
  m_q9 u_q9(.o()); m_qa u_qa(.clk(clk), .o()); m_qb u_qb(.o()); m_qc u_qc(.o());
  assign o = ext;
endmodule
