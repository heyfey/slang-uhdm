// § clsPropSpecTpFullName468
module top;
  class C #(type T = int);
    T m;
  endclass
  class env;
    C #(byte) comp;
  endclass
  env e;
endmodule
