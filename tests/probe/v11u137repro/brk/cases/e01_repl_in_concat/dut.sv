// § connReplTsRefThroughPort137
module sub(input logic [7:0] wmask_i, output logic [7:0] o);
  assign o = wmask_i;
endmodule
module top(input logic [3:0] a, output logic [7:0] o);
  sub u_dut(.wmask_i({{4{1'b1}}, a}), .o(o));
endmodule
