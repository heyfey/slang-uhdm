// § implicitTsEndAfterLineComment202v
module l02 (a, b, c);
  input
    a;
  output /* comment */
    b;
  input // line comment
    c;
  assign b = a & c;
  function automatic logic f(input
      x);
    return x;
  endfunction
endmodule
