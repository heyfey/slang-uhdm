// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[2][3] = '{'{1,2,3},'{4,5,6}};
  function void f();
    foreach (P[i,j]) begin end
  endfunction
endinterface
module top; endmodule
