module top(output int o);
   parameter int X [1:0] = '{0, 1};
   function automatic int theta();
      return X[0];
   endfunction
   if (1) begin : g
      assign o = theta();
   end
endmodule
