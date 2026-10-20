// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int b[2][3];
  int n;
  initial foreach (b[i]) foreach (b[i][j]) n += j;
endmodule
