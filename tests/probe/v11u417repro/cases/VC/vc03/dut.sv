// § foreachArrayNamesClass417
virtual class b;
  int v;
endclass
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
