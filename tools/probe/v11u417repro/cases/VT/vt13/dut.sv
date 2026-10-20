// § foreachArrayNamesTypedef417
typedef bit signed [15:0] b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
