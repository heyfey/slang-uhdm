// § defGenLhsSelIdxThroughBase257 (a generate loop inside an interface)
interface ifc; logic [7:0] st [3];
  for (genvar k = 0; k < 2; k++) begin : g assign st[k+1] = st[k]; end
endinterface
module top; ifc i(); endmodule
