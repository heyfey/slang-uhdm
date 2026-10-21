// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class C;
  typedef byte b_t;
  function void f();
    box #(box #(int)) b;
  endfunction
endclass
module top;
  C c;
endmodule
