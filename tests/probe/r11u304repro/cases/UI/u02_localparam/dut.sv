// § uninstIfaceForeachParamOwnTs304
interface ifc();
  localparam int P[3] = '{1,2,3};
  task t();
    foreach (P[i]) begin end
  endtask
endinterface
module top; endmodule
