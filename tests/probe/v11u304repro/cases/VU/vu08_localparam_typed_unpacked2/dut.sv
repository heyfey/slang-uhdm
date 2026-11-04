// § uninstIfaceForeachParamOwnTs304
interface ifc();
  localparam bit [1:0] P [2][2] = '{'{1,2},'{3,0}};
  function void f();
    foreach (P[i,j]) begin end
  endfunction
endinterface
module top; endmodule
