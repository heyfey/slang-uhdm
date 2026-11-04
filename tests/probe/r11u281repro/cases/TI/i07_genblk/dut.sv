// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    ifc u();
    assign u.d = i;
    assign o = u.d;
  end
endmodule
