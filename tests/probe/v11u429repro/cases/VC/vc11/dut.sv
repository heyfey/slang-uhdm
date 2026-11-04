// § unitClsCastPkgEnumTdTopListing429
package p;
  typedef enum logic [3:0] { A = 1, B = 2 } e_t;
endpackage
import p::*;
class C;
  function void f(int x);
    e_t v;
    v = e_t'(x);
  endfunction
endclass
module top; C c = new; endmodule
