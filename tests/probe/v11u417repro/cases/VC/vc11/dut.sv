// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  b b[3];
  int n;
  initial foreach (b[i]) if (b[i] != null) n++;
endmodule
