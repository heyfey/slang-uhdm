// § unitClsCastPkgEnumTdTopListing429
package q;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
endpackage
package p;
  typedef q::e_t e_t;
endpackage
import p::*;
class C;
  function void f(int x);
    e_t v;
    v = e_t'(x);
  endfunction
endclass
module top; C c = new; endmodule
