// § randWithCallParentByConsumer288 — the with-form scope randomize in every consumer position (if, if-else, ternary condition and branch, binary left and right, while, return, unary, parenthesized, comparison)
class pk;
  rand int x;
  int c, y, h;
  function void fa(); if (randomize(x) with { x > c; }) h = 1; endfunction
  function void fb(); if (randomize(x) with { x > c; }) h = 1; else h = 2; endfunction
  function void fc(); y = randomize(x) with { x > c; } ? 1 : 2; endfunction
  function void fd(); y = c ? randomize(x) with { x > c; } : 0; endfunction
  function void fe(); y = randomize(x) with { x > c; } && c; endfunction
  function void ff(); y = c && randomize(x) with { x > c; }; endfunction
  function void fg(); while (randomize(x) with { x > c; }) h = h + 1; endfunction
  function int fh(); return randomize(x) with { x > c; }; endfunction
  function void fi(); if (!(randomize(x) with { x > c; })) h = 1; endfunction
  function void fj(); h = c + (randomize(x) with { x > c; }); endfunction
  function void fk(); if (c > 0 && randomize(x) with { x > c; }) h = 1; endfunction
  function void fl(); if (randomize(x) with { x > c; } == 1) h = 1; endfunction
endclass
module top;
  pk p;
  initial begin p = new(); p.fa(); end
endmodule
