// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
    T v;
  endclass
endpackage
package q;
  import p::*;
  class C;
    function void f();
      box #(byte) b;
    endfunction
  endclass
endpackage
module top;
  q::C c;
endmodule
