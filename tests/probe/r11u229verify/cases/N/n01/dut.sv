// § newArrayBitSelIdxOpStripped224 (a conditional in the bit select index)
package p;
  class c;
    int arr [8];
    int arr2 [4][4];
    function void f(int k, int j);
      int la [];
      la = new[arr[k ? 1 : 2]];
    endfunction
  endclass
endpackage
module top;
  import p::*;
  c h;
  initial begin h = new; h.f(1, 2); end
endmodule
