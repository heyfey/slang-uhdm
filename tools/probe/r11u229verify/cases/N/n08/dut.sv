// § newArrayBitSelIdxOpStripped224 § newArrayVarSelStripped224 (a module function, not a class)
module top(output int o);
  int arr [8];
  int arr2 [4][4];
  function automatic int f(int k, int j);
    int la [];
    la = new[arr[k+1]];
    la = new[arr2[k][j]];
    return la.size();
  endfunction
  initial o = f(1, 2);
endmodule
