// § thisNetSurelogAnchor243
// a package that exports another package's class; the module imports the exporter and a third package
package p1;
  class c1;
    function void f(); $display("%p", this); endfunction
  endclass
endpackage
package p3;
  class c3;
    function void h(); $display("%p", this); endfunction
  endclass
endpackage
package p2;
  import p1::*;
  export p1::*;
  class c2;
    function void g(); $display("%p", this); endfunction
  endclass
endpackage
module top;
  import p3::*;
  import p2::*;
endmodule
