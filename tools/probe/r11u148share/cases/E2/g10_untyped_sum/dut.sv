module top(output int o);
   parameter int X = 1;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam L = X + 2;
      assign o = L;
   end
endmodule
