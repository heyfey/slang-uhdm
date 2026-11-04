// § newArrayVarSelStripped224 (a var_select of two different references)
package p;
  class c;
    int arr [8];
    int arr2 [4][4];
    function void f(int k, int j);
      int la [];
      la = new[arr2[k][j]];
    endfunction
  endclass
endpackage
module top;
  import p::*;
  c h;
  initial begin h = new; h.f(1, 2); end
endmodule
