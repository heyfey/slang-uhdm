// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[3] = '{1,2,3};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; ifc u(); endmodule
