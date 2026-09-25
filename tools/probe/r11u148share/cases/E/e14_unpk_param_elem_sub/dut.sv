module sub(output int o);
   parameter int X [1:0] = '{0, 1};
   function automatic int theta();
      return X[1];
   endfunction
   assign o = theta();
endmodule
module top(output int o);
   sub u(.o(o));
endmodule
