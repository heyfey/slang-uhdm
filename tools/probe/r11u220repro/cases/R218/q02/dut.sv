// § pkgQualOperandSpanInParam218
package pk; localparam int A = 3; endpackage
module sub #(parameter int W = {pk::A, 4'h0} >> 4, parameter int V = (pk::A > 1) ? pk::A : 0) (output int o);
  assign o = W + V;
endmodule
module top(output int o); sub u(.o(o)); endmodule
