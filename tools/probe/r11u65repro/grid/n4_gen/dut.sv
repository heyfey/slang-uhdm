// r11u65 n4 — SCOPES: a GENERATE block, an UNINSTANTIATED module, a module
// instantiated TWICE with different parameters, and a nested child.  OPS
// caution (d): generate-scope nets are a separate cell.
module leaf #(parameter int unsigned N = 2, parameter int unsigned D = 4)
  (output logic [N-1:0] o);
  typedef logic [N-1:0] a_t [D];
  a_t la;
  assign o = la[0];
endmodule

module never_inst #(parameter int unsigned N = 2, parameter int unsigned D = 4)
  (output logic [N-1:0] o);
  typedef logic [N-1:0] a_t [D];    // UNINSTANTIATED module: def view only
  a_t na;
  assign o = na[0];
endmodule

module dut #(
    parameter int unsigned N = 2,
    parameter int unsigned D = 4
) (
    output logic [N-1:0] o
);
  typedef logic [N-1:0] a_t [D];
  a_t top;

  logic [N-1:0] g0o, g1o, c0o, c1o;

  generate
    if (1) begin : gblk
      typedef logic [N-1:0] ga_t [D];   // typedef INSIDE the generate block
      ga_t ga;
      a_t  gb;                          // OUTER typedef used inside it
      assign g0o = ga[0] | gb[0];
    end
    for (genvar gi = 0; gi < 2; gi++) begin : gloop
      a_t gl;
      assign g1o = gl[0];
    end
  endgenerate

  leaf #(.N(N), .D(D)) c0 (.o(c0o));
  leaf #(.N(N), .D(2)) c1 (.o(c1o));   // SECOND instance, different D

  assign o = top[0] | g0o | g1o | c0o | c1o;
endmodule
