// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
    T v;
  endclass
endpackage
import p::*;
class C;
  function void f();
    box #(logic [3:0]) b;
    b = new;
  endfunction
endclass
module top;
  C c;
endmodule
