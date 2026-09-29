// § strLitContLineSpan220
interface bus;
  string s;
  initial s = "abc \
def";
endinterface
module top; bus b(); endmodule
