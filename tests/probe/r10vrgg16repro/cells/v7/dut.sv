// v7 — PROGRAM home and an interface port on a program, plus a module inside
// a gen-block whose port view sits under a gen_scope two levels down.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

program prog (ifc.mp p);
  initial $display("%0d", p.sig[0]);
endprogram

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [1:0] o);
  ifc #(16, 3) inst ();
  prog  up (.p(inst));
  child u1 (.p(inst), .o(o[0]));
  if (1) begin : g1
    if (1) begin : g2
      child u2 (.p(inst), .o(o[1]));
    end
  end
endmodule
