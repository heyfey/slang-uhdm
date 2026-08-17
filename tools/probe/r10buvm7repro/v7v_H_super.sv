typedef struct { int used; } stH_t;
class baseH; stH_t barr[4]; endclass
class derH extends baseH;
  function void fd(); super.barr[2].used++; endfunction
endclass
module topH; initial begin end endmodule
