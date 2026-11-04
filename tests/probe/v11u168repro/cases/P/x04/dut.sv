// § paramBaseSelTsInstName168
module sub #(parameter I = 3) (input [7:0] v, output [3:0] o);
for (genvar g = 0; g < 1; g++) begin : G
  wire [3:0] w = v[I:0];
  assign o = w;
end
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
