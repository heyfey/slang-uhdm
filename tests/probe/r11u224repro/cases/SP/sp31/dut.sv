// § strLitPpEscIdShift224
class c;
  string s = "a\nb` c";
endclass
module top(output string o);
  c h;
  initial begin h = new; o = h.s; end
endmodule
