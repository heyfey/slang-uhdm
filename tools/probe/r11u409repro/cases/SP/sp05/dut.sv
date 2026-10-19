// § streamBraceParenMacro409
`define UNP(VAR,TYPE) \
  begin \
    VAR = TYPE'({ << bit { VAR }}); \
  end
module top;
  typedef enum bit [1:0] { A, B, C } e_t;
  e_t v;
  initial begin
    `UNP(v, e_t)
  end
endmodule
