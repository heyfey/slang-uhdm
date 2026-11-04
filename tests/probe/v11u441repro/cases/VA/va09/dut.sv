// § sysCallEmptyArgEndPrevTok441
`define WW 5
module top;
  int a = 1, b = 2;
  initial begin
    $display("x", `WW,
             , b);
  end
endmodule
