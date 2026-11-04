// § streamBraceParenMacro409
module top;
  bit [7:0] v;
  bit arr[];
  initial begin
    arr = new [8];
    v = { << bit { arr }};
  end
endmodule
