// § parenCallWrittenArgs477
module top(output int z);
  import "DPI-C" function int cf(int a, int b = 3);
  initial z = (cf(1));
endmodule
