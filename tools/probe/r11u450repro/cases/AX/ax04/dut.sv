// § clsAssocVecIdxTs450
package p;
  class C;
    bit[7:0] mem[bit[7:0]];
    function void f();
      bit[7:0] loc[bit[7:0]];
    endfunction
  endclass
endpackage
module top;
  import p::*;
  p::C c = new;
endmodule
