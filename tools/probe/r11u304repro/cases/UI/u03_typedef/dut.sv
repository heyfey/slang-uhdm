// § uninstIfaceForeachParamOwnTs304
interface ifc();
  typedef int a_t [3];
  parameter a_t P = '{1,2,3};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
