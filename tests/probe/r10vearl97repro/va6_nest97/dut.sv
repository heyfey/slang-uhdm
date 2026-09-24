// v97 va6 -- SHARED DEF BODIES.  The § paramCastTsBySyntax fallback keys the
// declaration typespec by SYNTAX when an elaborated instance has its own
// InstanceBodySymbol.  Two overrides of one definition, a module instantiated
// from a generate loop, and a three-deep nest all reach the arm through that
// fallback -- the copied VpiSigned must follow every one of them.
module topva6;
  logic [31:0] a, b, c;
  midva6 #(.P(8))  u_m1(.o(a));
  midva6 #(.P(24)) u_m2(.o(b));
  genva6 #(.P(8))  u_g(.o(c));
endmodule
module midva6 #(parameter int P = 4) (output logic [31:0] o);
  logic [31:0] w;
  leafva6 #(.Q(P)) u_l(.o(w));
  assign o = w;
endmodule
module leafva6 #(parameter int Q = 4) (output logic [31:0] o);
  logic [3:0] m;
  localparam int          LW = $clog2(Q + 1);
  localparam int unsigned LU = $clog2(Q + 2);
  assign o = 32'(LW'(m)) + 32'(LU'(m));
endmodule
module genva6 #(parameter int P = 4) (output logic [31:0] o);
  logic [31:0] ww [2];
  for (genvar gi = 0; gi < 2; gi++) begin : gb
    leafva6 #(.Q(P + gi)) u_l(.o(ww[gi]));
  end
  assign o = ww[0] ^ ww[1];
endmodule
