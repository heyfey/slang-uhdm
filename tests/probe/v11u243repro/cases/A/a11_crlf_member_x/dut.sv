// § thisNetSurelogAnchor243
// CRLF: two packages, a this.member path and a task, imported against text order (out-of-body methods)
package p1;
  class c1;
    int v;
    extern task t();
  endclass
  task c1::t(); this.v = 1; $display("%p", this); endtask
endpackage
package p2;
  class c2;
    int w;
    extern function void f();
  endclass
  function void c2::f(); w = this.w + 1; endfunction
endpackage
module top;
  import p2::*;
  import p1::*;
endmodule
