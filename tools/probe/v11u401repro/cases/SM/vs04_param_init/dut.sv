// § strLitMacroRefSubst401
`define NM "world"
module top;
  parameter string S = "hi `NM";
  string s = "pre `NM post";
  initial $display("%s %s", S, s);
endmodule
