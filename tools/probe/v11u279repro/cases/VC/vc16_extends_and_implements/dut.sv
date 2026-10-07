// § extendsScopedBaseNameSpan279
package rp;
  class baseb; endclass
  interface class ic; pure virtual function void g(); endclass
endpackage
package pb;
  class ub extends rp::baseb implements rp::ic;
    virtual function void g(); endfunction
  endclass
endpackage
module top; pb::ub v; initial v = new(); endmodule
