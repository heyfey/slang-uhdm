// § streamBraceParenMacro409
`define UNP(VAR,TYPE) \
  begin \
    VAR = TYPE'({ << byte { arr }}); \
  end
module top;
  typedef bit [15:0] h_t;
  h_t v;
  byte arr[];
  initial begin
    arr = new [2];
    `UNP(v, h_t)
  end
endmodule
