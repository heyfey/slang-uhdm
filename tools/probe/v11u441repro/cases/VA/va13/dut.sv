// § sysCallEmptyArgEndPrevTok441
module sub;
  int a = 1, b = 2;
  initial begin
    $display("x", a,
             , b);
  end
endmodule
module top;
  sub u1();
  sub u2();
endmodule
