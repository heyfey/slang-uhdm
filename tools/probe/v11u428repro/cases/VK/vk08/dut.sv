// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int);
  endclass
endpackage
class B #(type U = int);
  function void f();
    p::box #(U) b;
  endfunction
endclass
module top;
  B #(byte) c;
endmodule
