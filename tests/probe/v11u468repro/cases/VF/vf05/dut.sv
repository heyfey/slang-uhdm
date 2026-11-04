// § clsPropSpecTpFullName468
class C #(type T = int);
  T m;
endclass
class env;
  C #(byte) a, b;
endclass
module top; env e; endmodule
