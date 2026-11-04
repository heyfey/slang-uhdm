// § sysCallEmptyArgIsIntZero401
module top;
  int a;
  initial begin $display(,,a); $display(a,,); $strobe(a,,a); end
endmodule
