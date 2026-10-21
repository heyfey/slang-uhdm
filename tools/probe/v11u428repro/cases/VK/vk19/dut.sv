// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class B #(type U = int);
  function void f();
    box #(int) b;
  endfunction
endclass
module top;
  B #(byte) c;
endmodule
