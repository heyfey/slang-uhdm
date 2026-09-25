// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
interface ifc;
  C#(shortint) c1 = new;
endinterface
module top ();
  ifc i();
endmodule
