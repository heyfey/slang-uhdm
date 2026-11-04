// § tpFormalIncludeOrder188
class base; endclass
class c #(type T = base);
  `include "m29.svh"
  task t2(output T o2);
    T l2;
    o2 = l2;
  endtask
endclass
module top; endmodule
