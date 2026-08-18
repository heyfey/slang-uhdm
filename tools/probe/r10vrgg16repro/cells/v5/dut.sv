// v5 — MODPORT with import tasks + a CLOCKING BLOCK in the interface, at
// module scope and inside a gen-if.  These change the interface_inst's other
// Compare-visible vectors, so a gate that mis-fires here shows up loudly.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic clk;
  logic [W-1:0] sig;
  function automatic logic rd();
    return sig[0];
  endfunction
  task automatic wr(input logic v);
    sig[0] <= v;
  endtask
  clocking cb @(posedge clk);
    input sig;
  endclocking
  modport mp (input sig, import rd, import wr, clocking cb);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [1:0] o);
  ifc #(16, 3) inst ();
  child u1 (.p(inst), .o(o[0]));
  if (1) begin : g
    child u2 (.p(inst), .o(o[1]));
  end
endmodule
