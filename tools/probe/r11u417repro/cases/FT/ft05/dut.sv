// § foreachArrayNamesTypedef417
class C;
  int v;
endclass
typedef C b;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
