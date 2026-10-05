// § thisNetSurelogAnchor243
// three packages, imported b, then c, then a; the first imported package's function holds the wire
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
    extern function new();
  endclass
  function cb::new();
    $display("%p", this);
  endfunction
endpackage
package c;
  class cc;
    extern function void f();
  endclass
  function void cc::f();
    $display("%p", this);
  endfunction
endpackage
module top;
  import b::*;
  import c::*;
  import a::*;
endmodule
