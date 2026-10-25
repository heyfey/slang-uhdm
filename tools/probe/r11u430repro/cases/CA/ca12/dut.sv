// § modArrConcatInitElemSize430
package p;
  int tab[2] = { 5, 6 };
endpackage
module top;
  import p::*;
  int x;
  initial x = tab[0];
endmodule
