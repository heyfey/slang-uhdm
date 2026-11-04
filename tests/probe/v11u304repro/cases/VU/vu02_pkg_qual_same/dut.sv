// § uninstIfaceForeachParamOwnTs304
package pk;
  parameter int P[2] = '{7,8};
endpackage
interface ifc();
  parameter int P[3] = '{1,2,3};
  function void f();
    foreach (pk::P[i]) begin end
  endfunction
endinterface
module top; endmodule
