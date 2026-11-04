// § tpFormalIncludeOrder188
class base; endclass
class c #(type T = base);
  task t2(output T o2);
    T l2;
    o2 = l2;
  endtask
  `include "m30.svh"
endclass
module top; endmodule
