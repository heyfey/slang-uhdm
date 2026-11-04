// § tpUseBindsDefDefault160
module sub #(parameter type A = logic [3:0], parameter type B = A) (input logic clk, output logic [3:0] o);
  B q;
  always_ff @(posedge clk) q <= '0;
  assign o = q;
endmodule
module top (input logic clk, output logic [3:0] o); sub u(.clk(clk), .o(o)); endmodule
