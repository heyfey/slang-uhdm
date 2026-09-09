// v226 b14 — a PARAMETERIZED interface: the default specialization is never
// instantiated, two non-default ones are.  Which views list processes?
interface bpm_if #(parameter int W = 8);
  logic [W-1:0] v;
  int           q;
  initial q = W;
  always_comb v = q[W-1:0];
endinterface

interface bpu_if #(parameter int W = 8);   // no specialization at all
  logic [W-1:0] v;
  int           q;
  initial q = W;
endinterface

module bpm_top;
  bpm_if #(4) a();
  bpm_if #(16) b();
endmodule
