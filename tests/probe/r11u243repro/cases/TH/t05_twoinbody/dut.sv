// § thisNetSurelogAnchor243
// two bare this references in one body, the second column first on a later line
package p;
  class c;
    extern function void f(c o);
  endclass
  function void c::f(c o);
    if (o == this) $display("a");
    $display("%p %p", o, this);
  endfunction
endpackage
module top;
  import p::*;
endmodule
