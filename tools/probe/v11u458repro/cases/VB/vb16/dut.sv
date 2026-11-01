// § subrAggCopyNamesByChain458
interface bus_if;
  typedef bit [7:0] a_t;
  typedef struct { a_t addr; bit [1:0] k; } op_s;
  op_s s;
  task automatic drive();
    op_s loc;
    op_s q[$];
    q.push_back(loc);
    s = loc;
  endtask
endinterface
module top;
  bus_if b1();
  bus_if b2();
endmodule
