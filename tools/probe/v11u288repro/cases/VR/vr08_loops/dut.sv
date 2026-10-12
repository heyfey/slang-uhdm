// § randWithCallParentByConsumer288 — the condition of else-if, do-while and for
class pk;
  rand int x; int c, h;
  function void fa(); if (c) h = 1; else if (randomize(x) with { x > c; }) h = 2; endfunction
  function void fb(); do h++; while (randomize(x) with { x > c; } && h < 3); endfunction
  function void fc(); for (int i = 0; randomize(x) with { x > i; }; i++) h++; endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
