// § tpTypedVarInitNameSpan275 — a type-parameter variable with an initializer inside an interface
interface ifc #(parameter type T = logic [3:0]) ();
  T x = 4'h6;
endinterface
module dut (output logic [3:0] o);
  ifc u ();
  assign o = u.x;
endmodule
