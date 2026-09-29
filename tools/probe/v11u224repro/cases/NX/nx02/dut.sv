// § newArrayVarSelStripped224
package p;
  int arr[4][4]; int k;
  function automatic int f();
    int la[];
    la = new[arr[k+1][k-1]];
    return la.size();
  endfunction
endpackage
module top(output int o); assign o = p::f(); endmodule
