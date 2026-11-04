// § tpOwnTsAtHeaderDefault188
package p;
class C4 #(type TP = int, int W = 4);
  function void f();
    TP  z_typaram;
    bit [W-1:0] w;
    z_typaram = w;
  endfunction
endclass
endpackage
module m4_mod;
  p::C4 #(int, 4) c4;
  initial c4 = new();
endmodule
