// § randWithCallParentByConsumer288 — a with-form scope randomize under a cast and under a unary minus
class pk;
  rand int x; int c, y;
  function void fa(); y = int'(randomize(x) with { x > c; }); endfunction
  function void fb(); y = -(randomize(x) with { x > c; }); endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
