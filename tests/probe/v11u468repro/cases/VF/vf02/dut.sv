// § clsPropSpecTpFullName468
class C #(type T = int);
  T m;
endclass
class outer;
  class inner;
    C #(byte) comp;
  endclass
  inner i;
endclass
module top; outer o; endmodule
