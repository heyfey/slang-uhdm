// § foreachArrayNamesTypedef417
typedef enum logic [1:0] {X, Y} b;
module top;
  logic [3:0] b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
