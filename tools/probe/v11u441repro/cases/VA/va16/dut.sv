// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    $display("x", a,
`ifdef NOPE
             , 3
`endif
             , b);
  end
endmodule
