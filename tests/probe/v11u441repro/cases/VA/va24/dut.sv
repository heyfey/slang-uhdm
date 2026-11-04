// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  initial begin
    $display("x", a, /* é */   
             , b);
  end
endmodule
