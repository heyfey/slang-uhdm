// § foreachArrayNamesTypedef417
typedef int b;
module top;
  int b[3][4];
  int n;
  initial foreach (b[i, j]) n += i + j;
endmodule
