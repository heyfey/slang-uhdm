// § defNetClassArrTsDimEnd293
// Two declarators of class handle arrays.
class C; int x; endclass
module top;
  C a [], b [$];
  int r_o;
  initial begin a = new[1]; b.push_back(a[0]); r_o = b.size(); end
endmodule
