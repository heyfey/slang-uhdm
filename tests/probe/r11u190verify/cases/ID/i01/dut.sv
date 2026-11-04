// § incDecBitSelWholeSpan181 § incDecMixedPathIsLvalue181 (r11u190: pre and post inc/dec with unary and call indices in a module FUNCTION)
module top;
  int a [8];
  int k;
  function automatic int f(int x); return x & 7; endfunction
  function automatic void bump(int i);
    a[-i + 7]++;
    ++a[~i & 7];
    a[f(i)]--;
    --a[f(i + 1)];
  endfunction
  initial bump(k);
endmodule
