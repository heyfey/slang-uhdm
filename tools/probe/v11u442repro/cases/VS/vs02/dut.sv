// § unitClassTdScopedSpan442
package pkg_a;
  class Cls #(type T = int, int N = 2);
  endclass
endpackage
typedef pkg_a::Cls#(byte, 3) u_t;
module top;
  u_t h [2];
endmodule
