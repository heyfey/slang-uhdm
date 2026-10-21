// § clsMethodLocalForeignPkgSpec428
package mgen;
  class box #(type T = int);
    T v;
  endclass
endpackage
package nuse;
  import mgen::*;
  typedef logic [2:0] tri_t;
  class C;
    function void f();
      box #(tri_t) b;
    endfunction
  endclass
endpackage
module top;
  nuse::C c;
endmodule
