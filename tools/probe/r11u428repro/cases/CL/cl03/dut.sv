// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
    T v;
  endclass
  class C;
    function void f();
      box #(byte) b;
    endfunction
  endclass
endpackage
module top;
  p::C c;
endmodule
