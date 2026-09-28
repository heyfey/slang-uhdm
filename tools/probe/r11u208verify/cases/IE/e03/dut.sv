// § implicitTsEndCrossesLineBreak200
module e03 (
  input
    a,
  input signed
    b,
  output //
    c
);
  function automatic logic f(input
     x, input
     // comment line
     y);
    return x ^ y;
  endfunction
  assign c = f(a, b);
endmodule
