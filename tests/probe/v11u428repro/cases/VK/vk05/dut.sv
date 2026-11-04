// § clsMethodLocalForeignPkgSpec428
package p;
  typedef bit [7:0] u8_t;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class C;
  function void f();
    box #(u8_t) b1;
    box #(u8_t) b2;
  endfunction
endclass
module top;
  C c;
endmodule
