// § ifaceTpUseBindsDefDefault281
interface ifc #(parameter type T = logic [3:0]);
  T d;
endinterface
module dut(input logic [3:0] i, output logic [7:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    ifc u();
    assign u.d = i;
    assign o[k*4 +: 4] = u.d;
  end
endmodule
