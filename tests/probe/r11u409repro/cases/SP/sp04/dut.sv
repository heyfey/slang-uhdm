// § streamBraceParenMacro409
module top;
  bit [7:0] v;
  bit [7:0] w;
  initial begin
    v = { >> 4 { w }};
    v = {<<{w}};
  end
endmodule
