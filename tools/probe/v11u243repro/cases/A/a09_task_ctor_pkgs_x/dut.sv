// § thisNetSurelogAnchor243
// the first imported package holds only a task, the second a function written earlier (out-of-body methods)
package p2;
  class c2;
    extern function void g();
  endclass
  function void c2::g(); $display("%p", this); endfunction
endpackage
package p1;
  class c1;
    extern task t();
    extern function new();
  endclass
  task c1::t(); $display("%p", this); endtask
  function c1::new(); $display("%p", this); endfunction
endpackage
module top;
  import p1::*;
  import p2::*;
endmodule
