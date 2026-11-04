// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[3] = '{1,2,3};
  int q[2];
  function void f();
    foreach (q[j]) foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
