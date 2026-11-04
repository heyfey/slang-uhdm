// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter logic [3:0] P[2] = '{4'h1, 4'h2};
  logic [3:0] s;
  function void f();
    foreach (P[k]) s = P[k];
  endfunction
endinterface
module top; endmodule
