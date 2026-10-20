// § foreachArrayNamesTypedef417
typedef union packed {logic [3:0] a; logic [3:0] c;} b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
