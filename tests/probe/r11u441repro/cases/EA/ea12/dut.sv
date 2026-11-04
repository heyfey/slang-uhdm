// § sysCallEmptyArgEndPrevTok441
`define SHOW(x) $display("x", x, , x)
module top;
  int a = 1;
  initial begin
    `SHOW(a);
    $display("x", a,
             , a);
  end
endmodule
