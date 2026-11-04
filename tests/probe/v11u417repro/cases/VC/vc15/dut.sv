// § foreachArrayNamesClass417
class B;
  int v;
endclass
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
