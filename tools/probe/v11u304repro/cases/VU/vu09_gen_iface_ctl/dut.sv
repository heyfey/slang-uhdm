// § uninstIfaceForeachParamOwnTs304
interface ifc #(parameter int N = 2)();
  parameter int P[3] = '{1,2,3};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; if (1) begin : g ifc u(); end endmodule
