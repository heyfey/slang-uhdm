// § randWithCallParentByConsumer288 — obj.randomize() with in a module, as an if condition and as an operand
class pk; rand int x; endclass
module top;
  pk p; int h;
  initial begin
    p = new();
    if (p.randomize() with { x > 0; }) h = 1;
    h = (p.randomize() with { x > 2; }) + h;
  end
endmodule
