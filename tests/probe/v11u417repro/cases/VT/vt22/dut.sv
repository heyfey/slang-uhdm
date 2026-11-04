// § foreachArrayNamesTypedef417
typedef int b;
interface ifc;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endinterface
module top;
  ifc u();
endmodule
