module top(output int o);
   parameter int P = 7;
   function automatic int f(input int a);
      return P + a;
   endfunction
   assign o = f(2);
endmodule
