// v11u83 b1 -- LAW A BREAK: the interface's FUNCTION-ref fixup binds by NAME
// over netMap.  With the hoist filing an imported package namesake into
// netMap, does the function's body ref still bind the INTERFACE's own member?
package pk;
  logic [7:0] fv;
endpackage

interface ifc ();
  import pk::*;
  logic [15:0] fv;
  function automatic logic [15:0] g();
    return fv;
  endfunction
  logic [15:0] r;
  assign r = g();
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = {16'd0, u_if.r};
endmodule
