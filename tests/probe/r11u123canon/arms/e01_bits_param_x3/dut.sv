module top(output int o1, output int o2, output int o3);
   localparam unsigned P = 15;
   assign o1 = $bits(P);
   assign o2 = $bits(P);
   assign o3 = $bits(P);
endmodule
