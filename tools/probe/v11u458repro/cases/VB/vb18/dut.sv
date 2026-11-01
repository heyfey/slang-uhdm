// § subrAggCopyNamesByChain458
module top;
  typedef bit [7:0] a_t;
  for (genvar i = 0; i < 2; i++) begin : g
    typedef struct { a_t addr; bit [1:0] k; } op_s;
    op_s s;
    function automatic op_s f();
      op_s r;
      r.addr = 8'(i);
      return r;
    endfunction
    initial s = f();
  end
endmodule
