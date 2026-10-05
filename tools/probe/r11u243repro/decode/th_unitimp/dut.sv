// § thisNetSurelogAnchor243
// a file-scope import of the later package beside a module import of the earlier one
package a;
  class ca;
    extern function void f();
  endclass
  function void ca::f();
    $display("%p", this);
  endfunction
endpackage
package b;
  class cb;
    extern function void f();
  endclass
  function void cb::f();
    $display("%p", this);
  endfunction
endpackage
import b::*;
module top;
  import a::*;
endmodule
