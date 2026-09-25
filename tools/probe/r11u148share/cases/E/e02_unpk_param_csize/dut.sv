module top(output int o);
   parameter int X [2] = '{5, 6};
   function automatic int theta();
      return X[1];
   endfunction
   assign o = theta();
endmodule
