// § implicitTsEndCrossesLineBreak200 § implicitTsEndAfterLineComment202v
module e01 (a, b, c, d);
  input signed
    a;
  input // one
        // two
    b;
  output

    c;
  input /* x */ // y
    d;
  parameter
    P = 1;
  assign c = a ^ b ^ d ^ P;
endmodule
