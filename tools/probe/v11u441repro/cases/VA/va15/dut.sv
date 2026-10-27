// § sysCallEmptyArgEndPrevTok441
`define D $display
module top;
  int a = 1, b = 2;
  initial begin
    `D("x", a,
             , b);
  end
endmodule
