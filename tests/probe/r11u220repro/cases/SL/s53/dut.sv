// § strLitShiftNeedsBacktick220
interface bus;
  string s;
  initial s = "a\\b\n";
endinterface
module top; bus b(); endmodule
