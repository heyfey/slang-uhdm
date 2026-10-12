// § randWithCallParentByConsumer288 — two and three identifiers, an else-if chain, a task, a nested if, an assert condition
class pk2;
  rand int x, y, z;
  int c, h;
  function void fa(); if (randomize(x, y) with { x > y; }) h = 1; endfunction
  function void fb(); h = randomize(x, y, z) with { x > z; } ? 1 : 0; endfunction
  function void fc(); if (c == 0) h = 0; else if (randomize(x) with { x < c; }) h = 2; endfunction
  task tk(); if (randomize(y) with { y != c; }) begin if (randomize(z) with { z == c; }) h = 3; end endtask
  function void fd(); assert (randomize(x) with { x > 0; }); endfunction
  function void fe(); h = c || randomize(x, y) with { x == y; }; endfunction
endclass
module top;
  pk2 p;
  initial begin p = new(); p.fa(); end
endmodule
