// § methTailIdxNestShape310
class item; int f; function int get(); return f; endfunction task run(); endtask endclass
class holder; int k; int idx[4]; endclass
class grid;
  item iarr[4]; holder h; int r;
  task probe();
    r = iarr[h.k].get();
    iarr[h.idx[1]].run();
  endtask
endclass
module top; endmodule
