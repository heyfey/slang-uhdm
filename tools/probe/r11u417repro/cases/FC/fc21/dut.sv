// § foreachArrayNamesClass417
class b #(int W = 1);
  int v;
endclass
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
