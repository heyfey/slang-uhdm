// § specArgTypedefNameShares468
// control: the argument written as the class name itself
class C #(type T = int, type U = int);
  T m;
endclass
class D;
  C #(int, D) x;
endclass
module top; D d; endmodule
