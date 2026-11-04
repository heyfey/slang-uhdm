// § macroStrBodyLen268
`define X1 hello
`define SN `"`X1 world`"
module top;
  int a, b;
  initial $display("%s %0d", `SN, a + b);
endmodule
