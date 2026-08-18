// r10rgg13 MUST-NOT-MOVE — gate clause (4), a BARE-IMPLICIT formal.  That is
// § elabCallFormal's window: this exporter re-binds P's OWN param_assign Rhs to
// the formal and re-runs adjustSize on it, so copying that Rhs would carry a
// value rewritten for a different law.
module mid #(
  parameter int P = 8'h07
)(
  output logic o
);
  function automatic bit [P-1:0][15:0] flp(n);
    bit [P-1:0][15:0] list;
    list = '0;
    list[0] = 16'(n);
    return list;
  endfunction
  localparam bit [P-1:0][15:0] LP = flp(P);
  assign o = LP[0][0];
endmodule

module top;
  logic o1, o2;
  mid #(.P(2))     u_dec (.o(o1));
  mid #(.P(8'h03)) u_hex (.o(o2));
endmodule
