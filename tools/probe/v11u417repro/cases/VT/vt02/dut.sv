// § foreachArrayNamesTypedef417
typedef logic [7:0] b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
