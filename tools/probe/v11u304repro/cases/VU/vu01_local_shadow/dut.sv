// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[3] = '{1,2,3};
  function automatic void f();
    localparam int P[2] = '{4,5};
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
