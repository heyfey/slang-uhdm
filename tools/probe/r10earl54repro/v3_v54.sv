// v54 VERIFIER ARM v3 — ESCAPED IDENTIFIERS (the earl53 lesson).
// The arm builds the ref_typespec fullname as `prefix + "." + ps.name`.  An
// escaped formal / instance / module name containing a DOT makes that string
// ambiguous, and an escaped name is also where a naive name walk trips.
module \snk-v3_54  (input [7:0] \a.port , output [7:0] \o!out );
  assign \o!out  = ~\a.port ;
endmodule
module v3_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] \w.esc , w2;
  \snk-v3_54  \u.inst  (.\a.port ({sel ? d[3:0] : {4{1'b0}}, 4'h1}), .\o!out (\w.esc ));
  \snk-v3_54  u_plain  (.\a.port ({sel ? d[3:0] : {4{1'b1}}, 4'h2}), .\o!out (w2));
  assign q = \w.esc  ^ w2;
endmodule
