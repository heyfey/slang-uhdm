package p;
class e; endclass
class c;
  typedef e qe_t[$];
  qe_t m;
  function qe_t get();
    qe_t r;
    r = m;
    return r;
  endfunction
endclass
endpackage
module top; endmodule
