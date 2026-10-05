// § thisNetSurelogAnchor243
// a task body ahead of a function body, the function's this on an earlier line inside a later-declared class
package p;
  class b;
    extern function void g();
  endclass
  class a;
    extern task t();
  endclass
  task a::t();
    $display("%p", this);
  endtask
  function void b::g();
    $display("%p", this);
  endfunction
endpackage
module top;
  import p::*;
endmodule
