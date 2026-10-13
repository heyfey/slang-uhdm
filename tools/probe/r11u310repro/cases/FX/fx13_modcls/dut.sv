// § clsLvTrailIdxNamesByChain310
module top;
  class holder; int idx[4]; endclass
  class grid;
    holder h; int r; int i;
    function void probe(); h.idx[i + 1] = r; h.idx[i ^ 1] <= r; endfunction
  endclass
endmodule
