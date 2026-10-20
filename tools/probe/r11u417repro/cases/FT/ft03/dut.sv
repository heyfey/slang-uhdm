// § foreachArrayNamesTypedef417
typedef struct packed { logic [3:0] a; } b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
