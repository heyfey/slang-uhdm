// § foreachArrayNamesClass417
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
class b;
  int v;
endclass
