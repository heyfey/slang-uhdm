// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[3] = '{1,2,3};
  class c;
    function void f();
      foreach (P[i]) begin end
    endfunction
  endclass
endinterface
module top; endmodule
