// § uninstIfaceForeachParamOwnTs304
interface ia();
  parameter int P[3] = '{1,2,3};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
interface ib();
  parameter int P[2] = '{1,2};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
