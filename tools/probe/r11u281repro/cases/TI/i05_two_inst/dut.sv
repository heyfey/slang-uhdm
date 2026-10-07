// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = logic [3:0], parameter int W = 2);
  T d;
  logic [W-1:0] e;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o, output logic [3:0] p);
  ifc u();
  ifc #(.W(3)) v();
  assign u.d = i;
  assign v.d = ~i;
  assign o = u.d;
  assign p = v.d;
endmodule
