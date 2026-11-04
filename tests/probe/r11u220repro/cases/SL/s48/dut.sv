// § strLitContLineSpan220
class c;
  string s = "abc \
def";
endclass
module top(output string o);
  c h;
  initial begin h = new; o = h.s; end
endmodule
