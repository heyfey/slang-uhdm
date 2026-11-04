// § thisNetSurelogAnchor243
// a package that exports another package's class; the module imports the exporter and a third package (out-of-body methods)
package p1;
  class c1;
    extern function void f();
  endclass
  function void c1::f(); $display("%p", this); endfunction
endpackage
package p3;
  class c3;
    extern function void h();
  endclass
  function void c3::h(); $display("%p", this); endfunction
endpackage
package p2;
  import p1::*;
  export p1::*;
  class c2;
    extern function void g();
  endclass
  function void c2::g(); $display("%p", this); endfunction
endpackage
module top;
  import p3::*;
  import p2::*;
endmodule
