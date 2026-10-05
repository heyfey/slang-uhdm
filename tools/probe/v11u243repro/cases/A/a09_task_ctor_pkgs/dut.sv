// § thisNetSurelogAnchor243
// the first imported package holds only a task, the second a function written earlier
package p2;
  class c2;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
package p1;
  class c1;
    task t(); $display("%p", this); endtask
    function new(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import p1::*;
  import p2::*;
endmodule
