// § bitSelParenIdxSpan181 (r11u190: nested parentheses, a parenthesized call, a parenthesized system call and parenthesized part-select bounds on rvalues)
module top;
  logic [15:0] a;
  logic y;
  logic [3:0] z;
  int i, j;
  localparam int W = 16;
  function automatic int f(int x); return x; endfunction
  initial begin
    y = a[((i) + (j))];
    y = a[(f(i))];
    y = a[(($clog2(W)))];
    z = a[(7):(4)];
    z = a[(i)+:(4)];
    y = a[(((i)))] ^ a[((f(j)))];
  end
endmodule
