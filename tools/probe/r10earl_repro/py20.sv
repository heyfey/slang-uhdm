// py20.sv — PASS 20 witness for work@jtag_mux (Top), decoded in pass 19 as:
//   param_assign[1] (`parameter logic [NumIOs-1:0] TieOffValues = '0`)
//     > Rhs constant `32'b0`
//       > vpiTypespec > logic_typespec   golden AT 11:13, ours LOC-LESS
//         > Ranges[0] > Left_expr        golden operation{op=11} (NumIOs-1),
//                                        ours an EMPTY constant {ct=0 sz=0}
// i.e. golden REUSES the declaration's own symbolic typespec for the
// ELABORATED param_assign Rhs where we synthesize a degenerate one.  Round 1
// (the bare parameter list) measured EQUAL, so the trigger is a USE: jtag_mux
// reads `TieOffValues[k]` from inside a for-generate.
module py20 #(
    parameter int                NumIOs       = 32,
    parameter logic [NumIOs-1:0] TieOffValues = '0,
    parameter logic [7:0]        LitBound     = '0
) (
    input  logic [NumIOs-1:0] in_i,
    output logic [NumIOs-1:0] o1,
    output logic [7:0]        o2
);

  logic en;
  assign en = in_i[0];

  for (genvar k = 0; k < NumIOs; k++) begin : gen_tie
    assign o1[k] = (en) ? TieOffValues[k] : in_i[k];
  end

  assign o2 = LitBound;

endmodule
