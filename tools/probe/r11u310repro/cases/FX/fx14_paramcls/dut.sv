// § clsLvTrailIdxNamesByChain310
class holder; int idx[4]; endclass
class grid #(int W = 2);
  holder h; int r; int i;
  function void probe(); h.idx[i + W] = r; endfunction
endclass
module top; grid #(3) g; endmodule
