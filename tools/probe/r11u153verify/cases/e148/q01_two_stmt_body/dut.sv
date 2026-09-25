// § evalFuncSelectKeepsCall148
module top(output int o);
   parameter int X [1:0] = '{3, 1};
   function automatic int theta();
      int t;
      t = X[1];
      return t;
   endfunction
   assign o = theta();
endmodule
