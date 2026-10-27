// § unitClassTdScopedSpan442
package pkg_a;
  class Cls #(int N = 1);
  endclass
endpackage
typedef pkg_a::Cls#(3) u_t;
module top;
  typedef pkg_a::Cls#(2) c_t;
  c_t h;
  u_t g;
endmodule
