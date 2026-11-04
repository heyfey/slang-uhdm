// § clsMethodLocalForeignPkgSpec428
package p;
  class box #(type T = int, int N = 2);
  endclass
endpackage
module top;
  import p::*;
  class C;
    function void f();
      begin
        box #(shortint, 5) b;
      end
    endfunction
  endclass
  C c;
endmodule
