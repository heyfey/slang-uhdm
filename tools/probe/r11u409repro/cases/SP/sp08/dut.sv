// § streamBraceParenMacro409
module top;
  typedef enum bit [1:0] { A, B, C } e_t;
  e_t v;
  bit arr[];
  initial begin
    arr = new [2];
    v = e_t'(({ << bit { arr }}));
  end
endmodule
