// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class B #(int N = 2);
  function void f();
    box #(logic [N-1:0]) b;
  endfunction
endclass
module top;
  B #(4) c;
endmodule
