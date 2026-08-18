// r10v68 arm v10 — the BARE-DECLARATION dimension of the adjustSize rule:
// a module-level IMPLICIT net driven from a gen scope, `var` with and without
// a written data type, and signing/dimension-only implicit types.
// MEASUREMENT ONLY.
module v10_bare68 (output logic [7:0] o);
  var                tv0;          // bare var                -> no typespec
  var logic [7:0]    tv1;          // var + written type      -> 8
  var signed [7:0]   tv2;          // implicit + signing+dims -> 8
  var        [3:0]   tv3;          // implicit + dims only    -> 4
  logic [7:0]        sink;
  assign imp2 = 1'b0;              // module-level IMPLICIT net
  for (genvar i = 5; i < 6; i++) begin : g
    if (i > 0) begin : b1
      assign imp2 = i;             // implicit net Lhs from a gen scope
      assign tv0  = i;
      assign tv1  = i;
      assign tv2  = i;
      assign tv3  = i;
    end
  end
  assign sink = tv1 ^ tv2 ^ {4'b0, tv3} ^ {7'b0, tv0} ^ {7'b0, imp2};
  assign o = sink;
endmodule
