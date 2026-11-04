// § paramBaseSelTsInstName168
package pk;
  parameter int I = 2;
endpackage
module sub import pk::*; (input [7:0] v, output [3:0] o);
wire [3:0] w = v[I+3:I];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
