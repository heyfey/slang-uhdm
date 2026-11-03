// § clsPropSpecTpFullName468
class C #(type T = int);
  T m;
endclass
class env;
  C #(C #(byte)) nest;
endclass
module top; env e; endmodule
