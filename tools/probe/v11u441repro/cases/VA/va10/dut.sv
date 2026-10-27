// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    $strobe("x", a,
             , b);
    $write("x", a,
             , b);
  end
endmodule
