// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  function void g(e_t r); endfunction
  class pb; e_t m; virtual function void vf(int x); endfunction endclass
endpackage
import p::*;
class C;
  static function e_t s(int x);
    return e_t'(x);
  endfunction
endclass
module top;
  initial begin p::e_t q; q = C::s(1); end
endmodule
