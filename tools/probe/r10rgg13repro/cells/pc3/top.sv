// r10rgg13 MUST-NOT-MOVE — gate clause (3), the GEN-SCOPE home.  Golden keeps a
// bare `ref(P)` in the gen-scope-homed param_assign (grid B, all twelve cells),
// because the substitution reads the gen scope's OWN netlist param_assigns.
module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
  function automatic bit [P-1:0][15:0] flp(int n);
    bit [P-1:0][15:0] list;
    list = '0;
    return list;
  endfunction
  if (1) begin : g
    localparam bit [P-1:0][15:0] LP = flp(P);
  end
  assign o = g.LP[0][0];
endmodule

module top;
  logic o1, o2;
  mid #(.P(2))     u_dec (.o(o1));
  mid #(.P(8'h03)) u_hex (.o(o2));
endmodule
