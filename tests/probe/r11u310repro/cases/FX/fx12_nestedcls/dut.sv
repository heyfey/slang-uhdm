// § clsLvTrailIdxNamesByChain310
class outer;
  class holder; int idx[4]; endclass
  class inner;
    holder h; int r; int i;
    function void probe(); h.idx[i * 2] = r; endfunction
  endclass
endclass
module top; endmodule
