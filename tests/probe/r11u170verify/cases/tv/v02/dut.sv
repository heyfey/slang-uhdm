// § defNetTypeParamPackedVec160
module sub #(parameter type T = logic) (input logic clk, output logic [7:0] o);
  T [3:0][1:0] q;
  always_ff @(posedge clk) q <= '1;
  assign o = q;
endmodule
module top (input logic clk, output logic [7:0] o); sub u(.clk(clk), .o(o)); endmodule
