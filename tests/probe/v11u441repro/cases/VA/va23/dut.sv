// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    $display("x", a,
`define FOO 1
             , b);
  end
endmodule
