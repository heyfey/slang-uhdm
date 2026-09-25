module top(output int o);
   parameter int X = 4;
   if (X > 1) begin : g
      localparam int L = X + 1;
      assign o = L;
   end
endmodule
