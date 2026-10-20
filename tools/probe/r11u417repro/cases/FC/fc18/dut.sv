// § foreachArrayNamesClass417
class b;
  int v;
endclass
interface ifc;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endinterface
module top;
  ifc u();
endmodule
