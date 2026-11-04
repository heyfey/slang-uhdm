// § strLitContLineSpan220
`define MSG "abc def"
module top(output string o);
  initial o = `MSG;
endmodule
