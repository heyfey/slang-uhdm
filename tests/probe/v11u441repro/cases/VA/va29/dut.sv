// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    $display("x", a,
             , b); $display("y", b,
       , a);
  end
endmodule
