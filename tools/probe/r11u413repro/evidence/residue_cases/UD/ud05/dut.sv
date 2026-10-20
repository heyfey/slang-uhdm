// residue (no law landed): unsized based literal parameter values (scr1's TIMEOUT, decoded only), see README
module sub #(parameter P = 'd7) (output int o);
  assign o = P;
endmodule
module top(output int o, output int q);
  sub u1(.o(o));
  sub #(.P('d9)) u2(.o(q));
endmodule
