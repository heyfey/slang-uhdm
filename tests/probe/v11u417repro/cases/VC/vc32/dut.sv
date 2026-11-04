// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  parameter int b[3] = '{1, 2, 3};
  int n;
  initial foreach (b[i]) n += b[i];
endmodule
