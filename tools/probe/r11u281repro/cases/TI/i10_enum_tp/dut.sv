// § ifaceInstTypeParamSharesDef281
interface ifc #(parameter type T = enum logic [1:0] {A, B, C});
  T d;
endinterface
module dut(output logic [1:0] o);
  ifc u();
  assign o = u.d;
endmodule
