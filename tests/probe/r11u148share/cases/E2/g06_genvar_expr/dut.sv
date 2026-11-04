module top(output int o [2]);
   for (genvar i = 0 ; i < 2 ; i++) begin : g
      localparam int L = i + 1;
      assign o[i] = L;
   end
endmodule
