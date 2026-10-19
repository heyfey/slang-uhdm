// § streamBraceParenMacro409
`define UNP(VAR,TYPE) VAR = TYPE'(({ << 2 { arr }}));
module top;
  typedef bit [7:0] w_t;
  w_t v;
  bit [1:0] arr[];
  initial begin
    arr = new [4];
    `UNP(v, w_t)
  end
endmodule
