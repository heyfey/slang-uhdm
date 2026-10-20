// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int b[3];
  int c[2];
  int n;
  initial foreach (b[i]) foreach (c[j]) n += i * j + b[i];
endmodule
