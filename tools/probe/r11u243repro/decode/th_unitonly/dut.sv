// § thisNetSurelogAnchor243
// a file-scope import alone: a constructor written first and a function after it
package b;
  class cb;
    extern function new();
    extern function void f();
  endclass
  function cb::new();
    $display("%p", this);
  endfunction
  function void cb::f();
    $display("%p", this);
  endfunction
endpackage
import b::*;
module top;
  cb h;
endmodule
