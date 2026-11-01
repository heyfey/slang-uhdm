// § subrAggCopyNamesByChain458
module sub;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; bit [1:0] k; } op_s;
  op_s s;
  task automatic t();
    op_s loc;
    loc = s;
  endtask
  initial t();
endmodule
module top;
  sub u1();
  sub u2();
endmodule
