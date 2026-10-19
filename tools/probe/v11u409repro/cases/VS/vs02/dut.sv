// § streamBraceParenMacro409
`define UNP(VAR) VAR = ({ << bit { arr }});
module top;
  bit [3:0] v;
  bit arr[];
  initial begin
    arr = new [4];
    `UNP(v)
  end
endmodule
