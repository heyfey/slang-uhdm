// r10v104 w3 -- DECLARED SHAPES the grid did not cross.  MEASUREMENT ONLY.
typedef logic [3:0] tw3_t;

// s1 -- MULTI-DIM packed, no reader
module m_s1 (output logic o); localparam logic [1:0][3:0] X = {8{1'b1}}; assign o = 1'b0; endmodule
// s2 -- MULTI-DIM packed, local select reader
module m_s2 (output logic o); localparam logic [1:0][3:0] X = {8{1'b1}}; logic [X[0][0]:0] w; assign w='0; assign o = w[0]; endmodule
// s3 -- PORT parameter, no reader
module m_s3 #(parameter logic [3:0] X = {4{1'b1}}) (output logic o); assign o = 1'b0; endmodule
// s4 -- PORT parameter, local select reader in a net range
module m_s4 #(parameter logic [3:0] X = {4{1'b1}}) (output logic o); logic [X[0]:0] w; assign w='0; assign o = w[0]; endmodule
// s5 -- operand width 2, no reader
module m_s5 (output logic o); localparam logic [3:0] X = {2{2'b10}}; assign o = 1'b0; endmodule
// s6 -- typedef-declared, no reader
module m_s6 (output logic o); localparam tw3_t X = {4{1'b1}}; assign o = 1'b0; endmodule
// s7 -- typedef-declared, local select reader in a net range
module m_s7 (output logic o); localparam tw3_t X = {4{1'b1}}; logic [X[0]:0] w; assign w='0; assign o = w[0]; endmodule
// s8 -- bit [W-1:0], no reader
module m_s8 (output logic o); localparam bit [31:0] X = {32{1'b1}}; assign o = 1'b0; endmodule
// s9 -- bit [W-1:0], local select reader in a net range
module m_s9 (output logic o); localparam bit [31:0] X = {32{1'b1}}; logic [X[0]:0] w; assign w='0; assign o = w[0]; endmodule
// s10 -- width 1 (earl55 fence: must stay int_typespec), no reader
module m_s10 (output logic o); localparam logic [0:0] X = {1{1'b1}}; assign o = 1'b0; endmodule
// s11 -- width 1 WITH a local select reader (earl55: still int_typespec)
module m_s11 (output logic o); localparam logic [0:0] X = {1{1'b1}}; logic [X[0]:0] w; assign w='0; assign o = w[0]; endmodule

module w3_shape104 (input logic ext, output logic o);
  m_s1 u_s1(.o()); m_s2 u_s2(.o()); m_s3 u_s3(.o()); m_s4 u_s4(.o());
  m_s5 u_s5(.o()); m_s6 u_s6(.o()); m_s7 u_s7(.o()); m_s8 u_s8(.o());
  m_s9 u_s9(.o()); m_s10 u_s10(.o()); m_s11 u_s11(.o());
  assign o = ext;
endmodule
