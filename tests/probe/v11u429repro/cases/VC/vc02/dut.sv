// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  function void g(e_t r); endfunction
  class pb; e_t m; virtual function void vf(int x); endfunction endclass
endpackage
import p::*;
class C extends pb;
  virtual function void vf(int x);
    m = e_t'(x + 1);
  endfunction
endclass
module top; C c = new; endmodule
