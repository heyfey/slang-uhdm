// § streamBraceParenMacro409
`define UNP(VAR,TYPE) VAR = TYPE'({ >> byte { arr }});
module top;
  typedef bit [15:0] w_t;
  w_t v;
  byte arr[];
  initial begin
    arr = new [2];
    `UNP(v, w_t)
  end
endmodule
