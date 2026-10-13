// § uninstIfaceForeachParamOwnTs304
`define PDECL parameter int P[3] = '{1,2,3};
interface ifc();
  `PDECL
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
