// § connReplTsRefThroughPort137
module sub(input logic [7:0] wmask_i, output logic [7:0] o);
  assign o = wmask_i;
endmodule
module top(output logic [7:0] o);
  sub u_dut({4{2'b10}}, o);
endmodule
