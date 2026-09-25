// § evalFuncSelectKeepsCall148
module top(output int o);
   parameter int X [1:0] = '{3, 1};
   function automatic int theta(int k);
      return X[k];
   endfunction
   assign o = theta(1);
endmodule
