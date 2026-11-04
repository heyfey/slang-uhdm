// § connReplTsRefThroughPort137
module sub(input logic [7:0] wmask_i, output logic [7:0] o);
  assign o = wmask_i;
endmodule
module top(output logic [7:0] o);
  if (1) begin : g
    sub u_dut(.wmask_i({8{1'b0}}), .o(o));
  end
endmodule
