// § randWithCallParentByConsumer288 — two with-form randomize calls as both operands of one operation, and nested operations
class pk;
  rand int x, w; int c, y;
  function void fa(); y = (randomize(x) with { x > c; }) + (randomize(w) with { w < c; }); endfunction
  function void fb(); y = (c > 0 && randomize(x) with { x > c; }) || c; endfunction
  function void fc(); y = c ? 1 : randomize(x) with { x > c; }; endfunction
endclass
module top; pk p; initial begin p = new(); p.fa(); end endmodule
