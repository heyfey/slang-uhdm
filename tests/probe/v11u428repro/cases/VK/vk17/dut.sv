// § clsMethodLocalForeignPkgSpec428
package tdp;
  typedef logic [9:0] w_t;
endpackage
package p;
  class box #(type T = int);
  endclass
endpackage
import p::*;
import tdp::*;
class C;
  function void f();
    box #(w_t) b;
    box #(int) c;
  endfunction
endclass
module top;
  C c;
endmodule
