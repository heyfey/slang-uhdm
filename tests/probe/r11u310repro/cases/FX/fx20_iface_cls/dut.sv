// § clsLvTrailIdxNamesByChain310
interface ifc;
  class holder; int idx[4]; endclass
  class grid; holder h; int r; int i; function void probe(); h.idx[i + 1] = r; endfunction endclass
endinterface
module top; ifc x(); endmodule
