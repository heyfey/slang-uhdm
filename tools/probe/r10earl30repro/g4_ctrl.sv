// r10earl30 arm g4_ctrl.sv — THE OVER-FIRE CONTROL.
//
// Every cell in here is a folded constant that today reads vpiConstType 9
// (vpiUIntConst) and, per this pass's census, AGREES with golden.  A blanket
// 9->7 must move NOTHING here.  Nothing in this file references an enum.
module g4_ctrl (input logic [31:0] q, input logic [3:0] s, output logic [31:0] o);

  localparam int         PW  = 8;
  localparam logic [7:0] PB  = 8'hA5;
  localparam int         PS  = PW * 2;
  logic [PW-1:0]  vec;         // k1 range bound from a param arithmetic fold
  logic [31:0]    mem [0:15];
  logic [31:0]    r;

  always_comb begin
    r = 32'd0;
    if (q == PW)      r[0] = 1'b1;   // k2 plain int localparam operand
    if (q == PB)      r[1] = 1'b1;   // k3 sized localparam operand
    if (q == PS)      r[2] = 1'b1;   // k4 multiply fold operand
    if (q == 32'd12)  r[3] = 1'b1;   // k5 sized literal
    if (q == 12)      r[4] = 1'b1;   // k6 unsized literal
    if (q == (PW+1))  r[5] = 1'b1;   // k7 inline arithmetic fold
    if (q[PW-1])      r[6] = 1'b1;   // k8 fold as a bit index
  end

  assign o = r | mem[s] | {24'd0, vec};

  // k9  port-connection default via a parametrized child
  g4_child #(.W(PW)) ch (.i(q[PW-1:0]));

endmodule

module g4_child #(parameter int W = 4) (input logic [W-1:0] i);
  localparam int WW = W + 1;      // k10 param-of-param fold
  logic [WW-1:0] x;
  assign x = {1'b0, i};
endmodule
