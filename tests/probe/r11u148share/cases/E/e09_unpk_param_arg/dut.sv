module top(output int o);
   parameter int X [2] = '{5, 6};
   function automatic int theta(input int i);
      return X[i];
   endfunction
   assign o = theta(1);
endmodule
