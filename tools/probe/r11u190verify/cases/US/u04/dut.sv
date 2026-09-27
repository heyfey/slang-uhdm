// § bareDecUnderscoreDropped181 (r11u190: separators in REAL and TIME literals, which are not bare decimals, beside a bare decimal delay)
module top;
  real r;
  int k;
  initial begin
    r = 1_0.5;
    r = 2_000.0e1_0;
    #1_0ns k = 1;
    #1_0 k = 1_2;
  end
endmodule
