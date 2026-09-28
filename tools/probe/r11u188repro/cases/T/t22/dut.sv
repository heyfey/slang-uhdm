// § tpFormalIncludeOrder188
class c #(type T = int);
  task t2(output T o2);
    T l2;
    o2 = l2;
  endtask
  `include "m22.svh"
endclass
module top; endmodule
