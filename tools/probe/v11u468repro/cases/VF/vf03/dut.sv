// § clsPropSpecTpFullName468
class C #(type T = int, type U = int);
  T m;
endclass
class env;
  rand C #(byte, shortint) comp;
  static C #(byte) s;
endclass
module top; env e; endmodule
