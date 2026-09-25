module top(output int o);
   for (genvar i = 0 ; i < 1 ; i++) begin : g
      localparam int L = 4 + 3;
      wire [31:0] w;
      assign w = L;
      assign o = w;
   end
endmodule
