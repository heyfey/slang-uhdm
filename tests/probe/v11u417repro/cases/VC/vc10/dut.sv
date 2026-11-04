// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int b[3][2];
  int n;
  initial foreach (b[i, j]) n += i + j;
endmodule
