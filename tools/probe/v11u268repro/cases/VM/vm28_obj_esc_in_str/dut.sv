// § macroStrBodyLen268
`define QE `"a\tb\\c`"
module top; int a;
  initial $display("%s %0d", `QE, a + 1);
endmodule
