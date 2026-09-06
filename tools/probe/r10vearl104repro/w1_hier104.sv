// r10v104 w1 -- HIERARCHICAL SELECT reads from the PARENT, in positions that
// are NOT a cont-assign.  MEASUREMENT ONLY.
// Each mN module holds exactly one `localparam logic [W-1:0] X = {W{1'b1}}`
// and NO local read of it; the only read is the parent's hierarchical select.

module m_n1_4  (output logic o); localparam logic [3:0]  X = {4{1'b1}};  assign o = 1'b0; endmodule
module m_n1_32 (output logic o); localparam logic [31:0] X = {32{1'b1}}; assign o = 1'b0; endmodule
module m_n3_4  (output logic o); localparam logic [3:0]  X = {4{1'b1}};  assign o = 1'b0; endmodule
module m_n4_4  (output logic o); localparam logic [3:0]  X = {4{1'b1}};  assign o = 1'b0; endmodule
module m_n5_4  (output logic o); localparam logic [3:0]  X = {4{1'b1}};  assign o = 1'b0; endmodule
module m_n6_4  (output logic o); localparam logic [3:0]  X = {4{1'b1}};  assign o = 1'b0; endmodule
module m_n7_4  (output logic o); localparam logic [3:0]  X = {4{1'b1}};  assign o = 1'b0; endmodule
module subw1 #(parameter int P = 0) (output logic z); assign z = |P; endmodule

module w1_hier104 (input logic ext, output logic o);
  m_n1_4  u_n1_4  (.o());
  m_n1_32 u_n1_32 (.o());
  m_n3_4  u_n3    (.o());
  m_n4_4  u_n4    (.o());
  m_n5_4  u_n5    (.o());
  m_n6_4  u_n6    (.o());
  m_n7_4  u_n7    (.o());

  // n1 -- hierarchical select in a NET declared RANGE
  logic [u_n1_4.X[0]:0]  wn1a;
  logic [u_n1_32.X[0]:0] wn1b;
  assign wn1a = '0;
  assign wn1b = '0;

  // n3 -- hierarchical select in another PARAMETER's initializer
  localparam int QN3 = u_n3.X[0];

  // n4 -- hierarchical select in an INSTANCE ARRAY dimension
  subw1 #(.P(1)) u_arr [u_n4.X[0]:0] (.z());

  // n5 -- hierarchical select in a LOOP-GENERATE stop expression
  for (genvar gi = 0; gi < u_n5.X[0]+1; gi++) begin : gen_n5
    logic wg; assign wg = 1'b0;
  end

  // n6 -- hierarchical select in a GENERATE-IF condition
  if (u_n6.X[0]) begin : gen_n6
    logic wh; assign wh = 1'b0;
  end else begin : gen_n6e
    logic wh; assign wh = 1'b1;
  end

  // n7 -- hierarchical select in a parameter OVERRIDE actual
  subw1 #(.P(u_n7.X[0])) u_ov (.z());

  assign o = ext ^ wn1a[0] ^ (QN3[0]);
endmodule
