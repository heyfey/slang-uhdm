// § clsLvTrailIdxNamesByChain310
class holder; int idx[4]; endclass
class grid;
  holder h; int r; int i;
  extern function void probe();
endclass
function void grid::probe(); h.idx[i + 1] = r; endfunction
module top; endmodule
