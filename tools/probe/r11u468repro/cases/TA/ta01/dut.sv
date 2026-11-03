// § specArgTypedefNameShares468
// a class property specialization whose argument names the class's own typedef of itself
class C #(type T = int, type U = int);
  T m;
endclass
class D;
  typedef D this_type;
  C #(int, this_type) x;
endclass
module top; D d; endmodule
