// § uninstIfaceForeachParamOwnTs304
package pk; parameter int P[3] = '{1,2,3}; endpackage
interface ifc();
  import pk::*;
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
