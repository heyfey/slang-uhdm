// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[3] = '{1,2,3};
  initial foreach (P[i]) begin end
endinterface
module top; endmodule
