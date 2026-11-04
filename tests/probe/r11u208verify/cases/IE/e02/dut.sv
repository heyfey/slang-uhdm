// § implicitTsEndSkipsCarriageReturn202v § implicitTsEndAfterLineComment202v § implicitTsEndCrossesLineBreak200
module e02 (a, b, c);
  input	// tab then comment
    a;
  input
	b;
  output signed // sgn
    c;
  assign c = a & b;
endmodule
