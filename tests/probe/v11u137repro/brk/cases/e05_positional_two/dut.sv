// § connReplTsRefThroughPort137
module sub(input logic [3:0] a, input logic [3:0] b, output logic [3:0] o);
  assign o = a ^ b;
endmodule
module top(output logic [3:0] o);
  sub u({4{1'b1}}, {2{2'b01}}, o);
endmodule
