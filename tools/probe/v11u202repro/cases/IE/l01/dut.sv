// § implicitTsEndCrossesLineBreak200
module sub #(parameter
    P = 1, localparam
  L = 2) (input
     a, output
  	 b);
  assign b = a;
endmodule
module l01 (input i, output o);
  sub u(.a(i), .b(o));
endmodule
