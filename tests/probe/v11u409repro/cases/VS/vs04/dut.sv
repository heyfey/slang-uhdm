// § streamBraceParenMacro409
`define PK(VAR,X) VAR = int'({ << bit { X }});
module top;
  int v;
  bit [31:0] x;
  initial begin
    `PK(v, x)
  end
endmodule
