// § clsMethodLocalForeignPkgSpec428
package zgen;
  class box #(type T = int);
  endclass
endpackage
package agen;
  class C;
    function void f();
      zgen::box #(byte) b;
    endfunction
  endclass
endpackage
module top;
  agen::C c;
endmodule
