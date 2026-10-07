// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter int N = 1, parameter type T = logic [3:0]);
  T d;
  logic [N-1:0] e;
endinterface
module dut(input logic [3:0] i, output logic [7:0] o);
  for (genvar k = 1; k < 3; k++) begin : g
    ifc #(.N(k)) u();
    assign u.d = i;
    assign u.e = '0;
    assign o[k*4-4 +: 4] = u.d;
  end
endmodule
