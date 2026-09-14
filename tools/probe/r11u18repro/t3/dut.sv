// t3: OVERRIDE + ELAB view.  A type parameter written `parameter` and one
// written `localparam` inside the port list, instantiated with an override on
// the non-local one, plus a re-pass one level down.
module leaf #(
    parameter  type PT = int,
    localparam type LT = logic [3:0]
) (output logic o);
  PT a; LT b;
  assign o = (|{a}) ^ (|{b});
endmodule
module mid #(parameter type MT = int) (output logic o);
  leaf #(.PT(MT)) u0 (.o(o));
endmodule
module dut(output logic o);
  mid #(.MT(logic [7:0])) u1 (.o(o));
endmodule
