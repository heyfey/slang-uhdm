// § subrAggCopyNamesByChain458
program prg;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; bit [1:0] k; } op_s;
  op_s s;
  task automatic t();
    op_s loc;
    loc = s;
  endtask
  initial t();
endprogram
module top;
  prg p1();
endmodule
