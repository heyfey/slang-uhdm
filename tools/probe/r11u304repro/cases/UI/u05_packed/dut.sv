// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter logic [1:0] P [0:2] = '{2'd1,2'd2,2'd3};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
