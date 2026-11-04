// v6 — HOMES: gen-case, a two-deep gen-for, and a gen-for whose actual is
// declared in the SAME iteration (a per-iteration interface instance).
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top #(parameter int SEL = 1) (output logic [4:0] o);
  ifc #(16, 3) inst ();
  case (SEL)
    1: begin : gc
      child u1 (.p(inst), .o(o[0]));       // gen-case, actual outside
      ifc #(16, 3) cinst ();
      child u2 (.p(cinst), .o(o[1]));      // gen-case, actual inside
    end
    default: begin : gd
      child u3 (.p(inst), .o(o[0]));
    end
  endcase
  for (genvar i = 0; i < 2; i++) begin : gf
    ifc #(16, 3) finst ();                 // per-iteration instance
    child u4 (.p(finst), .o(o[2]));        // actual in the SAME iteration
    for (genvar j = 0; j < 1; j++) begin : gg
      child u5 (.p(finst), .o(o[3]));      // actual one gen level up
      child u6 (.p(inst),  .o(o[4]));      // actual at module scope
    end
  end
endmodule
