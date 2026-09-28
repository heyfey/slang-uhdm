// § implicitTsEndSkipsCarriageReturn202v § implicitTsEndAfterLineComment202v
module e04 (a, b, c);
  input
    a;
  input // crlf comment
    b;
  output

    c;
  assign c = a | b;
endmodule
