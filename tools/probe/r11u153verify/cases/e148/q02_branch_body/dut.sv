// § evalFuncSelectKeepsCall148
module top(output int o);
   parameter int X [1:0] = '{3, 1};
   function automatic int theta();
      if (X[0] > 0) return X[1];
      else return 0;
   endfunction
   assign o = theta();
endmodule
