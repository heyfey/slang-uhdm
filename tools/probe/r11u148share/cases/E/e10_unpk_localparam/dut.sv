module top(output int o);
   localparam int L [2] = '{3, 4};
   function automatic int theta();
      return L[0] + 1;
   endfunction
   assign o = theta();
endmodule
