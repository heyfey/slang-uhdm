// § tpFormalIncludeOrder188
class c #(type T = int);
  `include "m21.svh"
  task t2(output T o2);
    T l2;
    o2 = l2;
  endtask
endclass
module top; endmodule
