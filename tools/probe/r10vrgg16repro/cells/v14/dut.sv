// v14 — BIND of a module carrying an interface port, into a target inside a
// generate block (the § bindIfaceTwinInParent46 neighbourhood), plus a plain
// bind at module scope.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module leaf (input logic a, output logic y);
  assign y = a;
endmodule

module top (output logic [2:0] o);
  ifc #(16, 3) inst ();
  logic a;
  leaf l1 (.a(a), .y(o[0]));
  if (1) begin : g
    leaf l2 (.a(a), .y(o[1]));
  end
  child u1 (.p(inst), .o(o[2]));
endmodule

bind leaf child b_c (.p(top.inst), .o());
