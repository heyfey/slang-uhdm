// § elabTpDefaultDefNamed163 § tpUseBindsDefDefault160 § defNetTypeParamPackedVec160
module ram #(parameter int W = 4, parameter type data_t = logic [W-1:0]) (input logic clk, output logic [7:0] o);
  data_t [1:0] q;
  always_ff @(posedge clk) q <= '0;
  assign o = q;
endmodule
module top (input logic clk, output logic [7:0] o); ram u(.clk(clk), .o(o)); endmodule
