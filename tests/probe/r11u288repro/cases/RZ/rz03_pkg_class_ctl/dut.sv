// § randWithCallParentByConsumer288 — a package class, an out-of-body method, the with-less form and the member form (controls)
package rp;
  class pc;
    rand int x;
    int c, h;
    extern function void ob();
    function void fa(); if (randomize(x)) h = 1; endfunction
    function void fb(); if (this.randomize() with { x > c; }) h = 2; endfunction
    function void fc(); h = randomize(x) ? 1 : 0; endfunction
  endclass
  function void pc::ob();
    if (randomize(x) with { x < c; }) h = 4;
    h = (randomize(x) with { x > 1; }) + 1;
  endfunction
endpackage
module top;
  import rp::*;
  pc p;
  initial begin p = new(); p.fa(); end
endmodule
