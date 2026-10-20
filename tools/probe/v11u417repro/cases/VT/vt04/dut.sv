// § foreachArrayNamesTypedef417
typedef int b[4];
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
