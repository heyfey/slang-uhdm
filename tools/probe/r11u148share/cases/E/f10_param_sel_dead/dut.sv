module top(output int o);
   parameter int X [2] = '{5, 6};
   function automatic int f(input int a);
      if (a > 0) return a;
      return X[0];
   endfunction
   assign o = f(3);
endmodule
