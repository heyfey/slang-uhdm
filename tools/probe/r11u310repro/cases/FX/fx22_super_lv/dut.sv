// § clsLvTrailIdxNamesByChain310
class holder; int idx[4]; endclass
class base; holder h; int r; int i; endclass
class grid extends base;
  function void probe(); super.h.idx[i + 1] = r; h.idx[i - 1] = r; endfunction
endclass
module top; endmodule
