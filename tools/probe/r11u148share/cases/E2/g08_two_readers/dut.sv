module top(output int o, output int p);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int L = 2 * 3;
      assign o = L;
      assign p = L;
   end
endmodule
