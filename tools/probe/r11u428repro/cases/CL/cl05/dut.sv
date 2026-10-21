// § clsMethodLocalForeignPkgSpec428
package p;
  typedef logic [7:0] w_t;
  class box #(type T = int);
    T v;
  endclass
endpackage
import p::*;
class C;
  function void f();
    begin
      box #(w_t) b;
    end
  endfunction
endclass
module top;
  C c;
endmodule
