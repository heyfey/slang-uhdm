// r11u57 — THE OVERRIDE, FROM THE ELABORATED SIDE.  This is the corpus
// witness `type_param_override_elem_sel`'s own shape: a child whose type
// parameter is OVERRIDDEN at the instantiation, with the buried `$bits` in
// the parameter port list.  The elaborated listing carries one copy per
// instance, so the arm asks whether the binding changes the decision.  It
// must not: the producer never consults the resolved type.
module child #(
    parameter type TP = logic,                  // default: 1 bit
    localparam int D = (1 << $bits(TP))
) (
    output logic o
);
  localparam int B = $bits(TP) + 1;             // module-body twin
  assign o = ^{D[0], B[0]};
endmodule
module dut (output logic o1, output logic o2);
  child                     u0 (.o(o1));        // default binding
  child #(.TP(logic [1:0])) u1 (.o(o2));        // OVERRIDDEN binding
endmodule
