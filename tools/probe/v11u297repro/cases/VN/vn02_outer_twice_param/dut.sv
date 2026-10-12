// § nestedDefPortsNeedShell297
module outer #(parameter int W = 2) (input logic [W-1:0] a, output logic [W-1:0] y);
  module inner #(parameter int N = 1) (input logic [N-1:0] i, output logic [N-1:0] o);
    assign o = i + 1'b1;
  endmodule
  inner #(.N(W)) u_in(.i(a), .o(y));
endmodule
module dut(input logic [1:0] a, input logic [3:0] b, output logic [1:0] y, output logic [3:0] z);
  outer u1(.a(a), .y(y));
  outer #(.W(4)) u2(.a(b), .y(z));
endmodule
