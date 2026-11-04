// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  function void g(e_t r); endfunction
  class pb; endclass
endpackage
import p::*;
class C;
  function void f(int x);
    e_t v;
    v = e_t'(x & 3);
  endfunction
endclass
module top;
  C c = new;
endmodule
