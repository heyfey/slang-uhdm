// § foreachArrayNamesClass417
class b;
  int v;
endclass
module sub;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
module top;
  sub u1();
  sub u2();
endmodule
