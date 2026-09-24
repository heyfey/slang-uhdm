// § connReplTsRefThroughPort137
module sub #(parameter W = 8)(input logic [W-1:0] wmask_i, output logic [W-1:0] o);
  assign o = wmask_i;
endmodule
module top(output logic [3:0] o);
  localparam N = 4;
  sub #(.W(N)) u_dut(.wmask_i({N{1'b1}}), .o(o));
endmodule
