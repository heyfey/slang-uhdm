// § clsMethodLocalForeignPkgSpec428
package mm;
  class box #(type T = int);
  endclass
endpackage
package aa;
  import mm::*;
  class C;
    function void f();
      box #(byte) b;
    endfunction
  endclass
endpackage
package zq;
  import mm::*;
  class D;
    function void f();
      box #(byte) b;
    endfunction
  endclass
endpackage
module top;
  aa::C c;
  zq::D d;
endmodule
