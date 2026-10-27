// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    assert (a == 1) else $error("x", a,
             , b);
    $fatal(1, "x", a,
             , b);
  end
endmodule
