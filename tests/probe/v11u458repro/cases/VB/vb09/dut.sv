// § subrAggCopyNamesByChain458
typedef enum bit [1:0] {R, W} k_e;
typedef struct { k_e kind; bit [7:0] addr; } op_s;
module hvl_top;
  op_s s;
  function automatic int f(k_e e);
    op_s loc;
    k_e x;
    x = e;
    return int'(x);
  endfunction
  initial s.addr = 8'(f(R));
endmodule
module hdl_top;
  op_s s2;
endmodule
