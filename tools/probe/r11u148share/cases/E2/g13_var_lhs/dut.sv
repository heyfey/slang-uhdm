module top(output int o);
   int v;
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int L = 2 + 3;
      assign v = L;
   end
   assign o = v;
endmodule
