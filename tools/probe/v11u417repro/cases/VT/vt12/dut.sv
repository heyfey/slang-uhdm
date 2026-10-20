// § foreachArrayNamesTypedef417
typedef int t;
typedef t b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
