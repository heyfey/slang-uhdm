// § paramBaseSelTsInstName168
module sub #(parameter I = 3, parameter E = 1) (input [7:0] v, output [3:0] o);
if (E) begin : G
  wire [3:0] w = v[I+3:I];
  assign o = w;
end else begin : H
  assign o = '0;
end
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
