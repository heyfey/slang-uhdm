// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class C;
  typedef logic [6:0] sv_t;
  function void f();
    box #(sv_t) b;
  endfunction
endclass
module top;
  C c;
endmodule
