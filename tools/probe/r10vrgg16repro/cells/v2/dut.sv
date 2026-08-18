// v2 — GENERIC interface port (`interface p`) and a PLAIN (non-modport)
// interface port, at module scope and in a gen-if; the def is SINGLY
// parameterized here so the plain-port drop arm is the only competitor.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module gchild (interface p, output logic o);
  assign o = p.sig[0];
endmodule

module pchild (ifc p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [3:0] o);
  ifc #(16, 3) inst ();
  gchild u1 (.p(inst),    .o(o[0]));
  pchild u2 (.p(inst),    .o(o[1]));
  if (1) begin : g
    gchild u3 (.p(inst),  .o(o[2]));
    pchild u4 (.p(inst),  .o(o[3]));
  end
endmodule
