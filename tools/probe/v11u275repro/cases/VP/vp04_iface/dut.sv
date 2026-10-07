// § tpPackedArrCaUnparent275 — an interface type parameter
interface ifc #(parameter type T = struct packed { logic a; logic b; } [1:0]) ();
  T x, y;
  assign y = x;
endinterface
module dut (input logic [3:0] i, output logic [3:0] o);
  ifc u ();
  assign u.x = i;
  assign o = u.y;
endmodule
