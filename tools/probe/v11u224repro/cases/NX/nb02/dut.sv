// § newArrayVarSelStripped224
module top(output int o);
  int arr[4][4]; int k;
  function automatic int f();
    int la[];
    la = new[arr[k+1][k-1]];
    return la.size();
  endfunction
  initial begin k = 1; o = f(); end
endmodule
