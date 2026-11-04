// § defNetModTdCloneBoundSyntax440
module m #(parameter w = 8) (input clk, output logic [w-1:0] o);
  typedef logic [w-1:0] t;
  t z;
  always_ff @(posedge clk) z <= z + 1'b1;
  assign o = z;
endmodule
module top(input clk, output [7:0] o); m u(.clk(clk), .o(o)); endmodule
