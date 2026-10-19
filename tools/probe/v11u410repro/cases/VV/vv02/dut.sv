// § modVirtIfaceTd410
interface I; logic a; endinterface
module top;
  typedef virtual I vi_t;
  vi_t h [2];
  function automatic void f(vi_t x); endfunction
  class C; vi_t m; endclass
endmodule
