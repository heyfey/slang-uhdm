// § tpPackedArrCaUnparent275 — an interface type parameter, assigned inside the interface
interface ifc #(parameter type T = struct packed { logic a; logic b; } [1:0]) ();
  T x;
  logic [3:0] y;
  assign x = y;
endinterface
module dut (output logic o);
  ifc u ();
  assign o = ^u.x;
endmodule
