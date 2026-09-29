// § strLitContLineSpan220
`define M "ab \
cd"
module top(output string o);
  initial o = `M;
endmodule
