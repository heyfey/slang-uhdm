// § randWithCallParentByConsumer288 — a package class task with the randomize in a comparison right side and a ternary condition
package rp;
  class pk;
    rand int x; int c, y;
    task ta(); y = c < (randomize(x) with { x > c; }); endtask
    task tb(); y = (randomize(x) with { x > c; }) ? c : 0; endtask
  endclass
endpackage
module top; import rp::*; pk p; initial begin p = new(); p.ta(); end endmodule
