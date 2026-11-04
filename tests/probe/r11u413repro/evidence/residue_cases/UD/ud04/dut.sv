// residue (no law landed): unsized based literal parameter values (scr1's TIMEOUT, decoded only), see README
module top(output int o);
  localparam int T = 'd5;
  assign o = T;
endmodule
