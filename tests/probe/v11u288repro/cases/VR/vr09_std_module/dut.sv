// § randWithCallParentByConsumer288 — std::randomize with a with clause in a module process, as an if condition and as an operand
module top;
  int v, h;
  initial begin
    if (std::randomize(v) with { v > 0; v < 9; }) h = 1;
    h = (std::randomize(v) with { v > 2; }) && h;
  end
endmodule
