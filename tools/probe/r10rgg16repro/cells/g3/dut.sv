// g3 — PASSTHROUGH: the child's modport port is connected to the ENCLOSING
// module's own interface PORT, at module scope (c1) and inside a gen scope (c2).
// Exactly Rggen's `.bus_if(register_15_bus_if)` shape.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module leaf (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module mid (ifc.mp p, output logic o1, output logic o2);
  // c1  module scope passthrough  (the port copy IS a sub-instance of `mid`)
  leaf u1 (.p(p), .o(o1));
  // c2  gen-scope passthrough     (the port copy is NOT a sub-instance of `g`)
  if (1) begin : g
    leaf u2 (.p(p), .o(o2));
  end
endmodule

module top (output logic o1, output logic o2, output logic o3, output logic o4);
  ifc #(16, 3) inst ();
  ifc #(8, 2)  inst2 ();
  mid u_m  (.p(inst),  .o1(o1), .o2(o2));
  mid u_m2 (.p(inst2), .o1(o3), .o2(o4));
endmodule
