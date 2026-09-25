// § paramBaseSelTsInstName168
package pk;
  parameter int I = 2;
endpackage
module sub (input [7:0] v, output [3:0] o);
wire [3:0] w = v[pk::I+3:pk::I];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
