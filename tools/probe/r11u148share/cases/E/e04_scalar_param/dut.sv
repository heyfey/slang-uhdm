module top(output int o);
   parameter int P = 7;
   function automatic int theta();
      return P;
   endfunction
   assign o = theta();
endmodule
