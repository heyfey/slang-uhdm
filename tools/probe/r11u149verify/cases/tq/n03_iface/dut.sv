// § defNetTypeParamPackedDim144
interface ifc #(parameter type dtype = struct packed { logic [1:0] a; logic b; });
  dtype [3:0] mem;
endinterface
module dut(output logic [2:0] o);
  ifc u();
  assign u.mem = '0;
  assign o = u.mem[1];
endmodule
