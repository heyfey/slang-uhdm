// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  function void g(e_t r); endfunction
endpackage
import p::*;
class C;
  function void f(int x);
    e_t v;
    v = e_t'(x);
  endfunction
endclass
package r;
  import p::*;
  function automatic e_t rf(int x);
    return e_t'(x);
  endfunction
endpackage
module top; C c = new; initial $display(r::rf(2)); endmodule
