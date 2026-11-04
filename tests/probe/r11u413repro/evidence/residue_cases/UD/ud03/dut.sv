// residue (no law landed): unsized based literal parameter values (scr1's TIMEOUT, decoded only), see README
module top(output int o);
  localparam T = 'h10;
  localparam U = 'b101;
  localparam V = 'o17;
  assign o = T + U + V;
endmodule
