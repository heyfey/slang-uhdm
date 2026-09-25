module top(output int o);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam L = 5;
      assign o = L;
   end
endmodule
