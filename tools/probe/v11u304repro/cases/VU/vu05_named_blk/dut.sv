// § uninstIfaceForeachParamOwnTs304
interface ifc();
  parameter int P[3] = '{1,2,3};
  task t();
    begin : b
      foreach (P[i]) begin end
    end
  endtask
endinterface
module top; endmodule
