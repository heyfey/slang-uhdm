// § newArrayBitSelIdxOpStripped224
module top(output int o);
  int arr[4]; int k;
  function automatic int f();
    int la[];
    la = new[arr[k+1] + 2];
    return la.size();
  endfunction
  initial begin arr = '{1,2,3,4}; k = 0; o = f(); end
endmodule
