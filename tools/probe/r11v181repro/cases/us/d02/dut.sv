// § bareDecUnderscoreDropped181 (v11u181 break: trailing and doubled separators, a macro-born literal, a $display argument, a negation, a big value)
`define LIM 2_5_6
module top(output int y);
  initial begin
    y = 10_;
    y = 1__0 + `LIM;
    y = -1_000;
    $display("%d", 4_294_967_295);
    y = 18_446_744_073_709_551_615 == 0;
  end
endmodule
