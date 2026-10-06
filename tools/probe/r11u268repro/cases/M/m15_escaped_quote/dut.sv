// § macroStrBodyLen268
`define EN kk
`define EA 8
`define E1 `"`\`"`EN``-```EA`\`"`"
module top;
  int a, b;
  initial $display("%s %0d", `E1, a + b);
endmodule
