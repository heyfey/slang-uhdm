// § modTdRangeClogKeeps434
package p;
  parameter int P = 8;
  typedef logic [$clog2(P)-1:0] t;
endpackage
module top;
  p::t x;
endmodule
