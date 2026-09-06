// r10v104 w6 -- further HOMES and READ POSITIONS.  MEASUREMENT ONLY.
module subw6 #(parameter int P = 0) (output logic z); assign z = |P; endmodule

// r1 -- home = PROGRAM, no read
program pr_r1 (); localparam logic [3:0] X = {4{1'b1}}; initial begin end endprogram
// r2 -- home = PROGRAM, local select read in a net range
program pr_r2 (); localparam logic [3:0] X = {4{1'b1}}; logic [X[0]:0] w; initial begin end endprogram

// r3 -- select read reached only through a MODPORT-ported interface
interface ifw6 (); localparam logic [3:0] XM = {4{1'b1}}; logic d; assign d=1'b0;
  modport mp (input d); endinterface
module usr_r3 (ifw6.mp i, output logic o); assign o = 1'b0; endmodule

// r4 -- the parameter's name is SHADOWED by a same-named net that IS selected
module m_r4 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  if (1) begin : gs4
    logic [7:0] X;             // a DIFFERENT X
    logic w; assign w = X[0];  // selects the NET, not the parameter
  end
  assign o = 1'b0;
endmodule

// r5 -- select read only inside a CHECKER
module m_r5 (input logic clk, output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic w5; assign w5 = 1'b0;
  assign o = 1'b0;
endmodule

// r6 -- select read in an ALWAYS block AND a bare read in a module cont-assign
module m_r6 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic a6, b6; assign a6 = |X;
  always_comb b6 = X[0];
  assign o = 1'b0;
endmodule

// r7 -- select read ONLY in a module-level ASSERT PROPERTY
module m_r7 (input logic clk, output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  assert property (@(posedge clk) X[0]);
  assign o = 1'b0;
endmodule

// r8 -- select read in an INITIAL block's variable declaration range
module m_r8 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  initial begin
    automatic logic [X[0]:0] lv = '0;
    if (lv[0]) ;
  end
  assign o = 1'b0;
endmodule

// r9 -- select read in a NESTED module's body (nested module declaration)
module m_r9 (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  module inner_r9 (output logic zz);
    logic [X[0]:0] wi; assign wi = '0;
    assign zz = wi[0];
  endmodule
  inner_r9 u_in (.zz());
  assign o = 1'b0;
endmodule

// ra -- select read only via a PART select X[1:0]
module m_ra (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic [1:0] wa; assign wa = X[1:0];
  assign o = 1'b0;
endmodule

// rb -- select read only in an INDEXED part select X[0+:2] in a net range
module m_rb (output logic o);
  localparam logic [3:0] X = {4{1'b1}};
  logic [X[0+:2]:0] wb; assign wb = '0;
  assign o = 1'b0;
endmodule

module w6_more104 (input logic clk, input logic ext, output logic o);
  pr_r1 u_r1 ();
  pr_r2 u_r2 ();
  ifw6 u_if6 ();
  usr_r3 u_r3 (.i(u_if6.mp), .o());
  m_r4 u_r4(.o()); m_r5 u_r5(.clk(clk), .o()); m_r6 u_r6(.o());
  m_r7 u_r7(.clk(clk), .o()); m_r8 u_r8(.o()); m_r9 u_r9(.o());
  m_ra u_ra(.o()); m_rb u_rb(.o());
  assign o = ext;
endmodule
