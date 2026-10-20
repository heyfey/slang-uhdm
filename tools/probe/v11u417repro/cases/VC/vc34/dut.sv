// § foreachArrayNamesClass417
module top;
  class b;
    int v;
  endclass
  inner u();
endmodule
module inner;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
