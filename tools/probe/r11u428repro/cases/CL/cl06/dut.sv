// § clsMethodLocalForeignPkgSpec428
package zgen;
  class box #(type T = int);
  endclass
endpackage
package ause;
  import zgen::*;
  class C;
    function void f();
      box #(byte) b;
    endfunction
  endclass
endpackage
module top;
  ause::C c;
endmodule
