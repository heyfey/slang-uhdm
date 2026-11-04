// § oneTickUpperBNormalized425
package p;
  parameter logic B = 1'B1;
endpackage
module top(input a, output o);
  import p::*;
  assign o = a & B & 1'B1;
endmodule
