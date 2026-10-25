// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
module sub #(parameter Q = 0) (output [3:0] o);
  assign o = Q;
endmodule
module top(output [3:0] o);
  sub #(.Q(p::B)) u(o);
endmodule
