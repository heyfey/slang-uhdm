// § clsMethodLocalForeignPkgSpec428
package agen;
  class box #(type T = int);
  endclass
endpackage
package zuse;
  import agen::*;
  class C;
    function void f();
      box #(byte) b;
    endfunction
  endclass
endpackage
module top;
  zuse::C c;
endmodule
