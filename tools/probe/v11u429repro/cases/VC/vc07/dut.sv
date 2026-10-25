// § unitClsCastPkgEnumTdTopListing429
package q;
  parameter W = 6;
  typedef logic [W-1:0] bt;
endpackage
package p;
  import q::*;
  typedef enum bt { A = 1, B = 2 } e_t;
endpackage
import p::*;
class C;
  function void f(int x);
    e_t v;
    v = e_t'(x);
  endfunction
endclass
module top; C c = new; endmodule
