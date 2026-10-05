// § thisNetSurelogAnchor243
// CRLF: two packages, a this.member path and a task, imported against text order
package p1;
  class c1;
    int v;
    task t(); this.v = 1; endtask
  endclass
endpackage
package p2;
  class c2;
    int w;
    function void f(); w = this.w + 1; endfunction
  endclass
endpackage
module top;
  import p2::*;
  import p1::*;
endmodule
