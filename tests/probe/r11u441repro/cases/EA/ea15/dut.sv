// § sysCallEmptyArgEndPrevTok441
`define SHOW2(x) $display("x", x, \
     , x)
module top;
  int a = 1;
  initial begin
    `SHOW2(a);
  end
endmodule
