// § strLitPpEscIdShift224
interface ifc;
  string s;
  initial s = "a\nb` c";
endinterface
module top;
  ifc u();
endmodule
