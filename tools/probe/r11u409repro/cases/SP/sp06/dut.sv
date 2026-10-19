// § streamBraceParenMacro409
`define UNP(VAR,TYPE) \
  begin \
    VAR = TYPE'(({ << 2 { arr }})); \
  end
module top;
  typedef enum bit [1:0] { A, B, C } e_t;
  e_t v;
  bit arr[];
  initial begin
    arr = new [2];
    `UNP(v, e_t)
  end
endmodule
