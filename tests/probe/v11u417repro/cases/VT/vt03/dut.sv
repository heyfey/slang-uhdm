// § foreachArrayNamesTypedef417
typedef string b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
