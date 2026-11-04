// § importCloneSharesHomeReturn218 — c08_importer_class: the importer declares its own class extending the imported one (svaunit shape)
package p1;
  class c;
    extern function int f();
  endclass
  function int c::f();
    return 7;
  endfunction
endpackage
package p2;
  import p1::*;
  class d extends c;
    function int h();
      return f();
    endfunction
  endclass
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
