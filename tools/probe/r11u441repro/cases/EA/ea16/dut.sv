// § sysCallEmptyArgEndPrevTok441
`define SHOW3(x) $display("x", x, , x)
module top;
  int a = 1;
  initial begin
    $display("x", a,
             , a); `SHOW3(a);
  end
endmodule
