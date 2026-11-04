// § implicitTsEndCrossesLineBreak200
module l01(a, b, o);
input
	a;
input   /* c */
  b;
output
     o;
assign o = a | b;
endmodule
