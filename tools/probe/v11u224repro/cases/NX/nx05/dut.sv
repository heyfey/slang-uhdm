// § newArrayVarSelStripped224
package p;
class c;
  int arr[4][4]; int k;
  function int g(int x); return x; endfunction
  function void f();
    int la[];
    la = new[arr[g(k)][k]];
    la = new[arr[k][k][1:0]];
  endfunction
endclass
endpackage
module top; endmodule
