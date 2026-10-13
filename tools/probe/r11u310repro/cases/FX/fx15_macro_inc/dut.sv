// § clsLvTrailIdxNamesByChain310
`include "defs.svh"
class holder; int idx[4]; endclass
class grid;
  holder h; int r; int i;
  function void probe(); h.idx[`NXT(i)] = r; `SETH(h, i) endfunction
endclass
module top; endmodule
