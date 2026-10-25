// § xzPkgLeafFoldIsRhsCopy427
package p;
  parameter B = 4'b1x01;
endpackage
module a(output [3:0] o);
  assign o = p::B;
endmodule
module top(output [3:0] o, o2);
  a u(o);
  assign o2 = p::B;
endmodule
