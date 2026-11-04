// § foreachArrayNamesClass417
class outer;
  class b;
    int v;
  endclass
endclass
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
