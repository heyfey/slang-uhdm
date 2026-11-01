// § pkgTdForeignSpecParams460 (value parameter)
package u;
  class S #(int N = 1);
    bit [N-1:0] x;
  endclass
endpackage
package a;
  import u::*;
  typedef S #(4) a_t;
endpackage
module top;
  import a::*;
  a_t h;
  initial h = new;
endmodule
