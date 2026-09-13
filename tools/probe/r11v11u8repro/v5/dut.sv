// v5 — an EMPTY MACRO ARGUMENT (not a continuation) also parks trivia in
// slang's emptyArgTrivia. Does it leak into the stringification, and does
// golden agree?
`define TWO(__a,__b) `"__a__b`"
`define TWOW(__a,__b) `"  __a__b`"
module top;
  initial begin
    $display("%0s", `TWO(   ,yy));
    $display("%0s", `TWOW(   ,yy));
    $display("%0s", `TWO(xx,   ));
  end
endmodule
