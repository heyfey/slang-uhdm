// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  always @(a) begin
    asg: o = a;
  end
endmodule
