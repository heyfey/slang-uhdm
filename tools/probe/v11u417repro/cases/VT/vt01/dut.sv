// § foreachArrayNamesTypedef417
typedef enum {A, B} b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
