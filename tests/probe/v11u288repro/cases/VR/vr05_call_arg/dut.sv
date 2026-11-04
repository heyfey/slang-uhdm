// § randWithCallParentByConsumer288 — a with-form scope randomize as a function argument and a case condition
class pk;
  rand int x; int c, y;
  function int g(int a); return a; endfunction
  function void fa(); y = g(randomize(x) with { x > c; }); endfunction
  function void fb(); case (randomize(x) with { x > c; }) 1: y = 1; default: y = 0; endcase endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
