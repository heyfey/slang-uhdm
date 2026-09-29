// § strLitContOwnerEnd224
class k;
  bit c;
  string s = c ? "x" : "ab \
cd";
endclass
module top(output string o);
  k h;
  initial begin h = new; o = h.s; end
endmodule
