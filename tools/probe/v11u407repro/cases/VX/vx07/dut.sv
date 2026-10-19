// § typedParamXzLitSize407
package p;
  parameter int pp = 1'bx;
  class c #(parameter int P = 2'bx0);
    int v = P;
  endclass
endpackage
module top(output int o);
  assign o = p::pp;
endmodule
