// residue (no law landed): see README
module sub #(parameter T = 'd12) (output int y);
  assign y = T;
endmodule
module top(output int y);
  sub #(.T('d5)) u(.y(y));
endmodule
