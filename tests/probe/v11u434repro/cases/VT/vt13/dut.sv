// § modTdRangeClogKeeps434
package p; parameter int N = 16; endpackage
module top;
  typedef logic [$clog2(p::N)-1:0] t;
  t x;
endmodule
