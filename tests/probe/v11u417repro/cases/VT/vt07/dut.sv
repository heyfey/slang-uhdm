// § foreachArrayNamesTypedef417
typedef struct {int x;} b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
