// § elabCastKeyBindsDefNet286 — instances inside a for-generate and an if-generate
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
endpackage
module leaf import q::*; (output logic [7:0] o);
  localparam p2_t A = p2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
module top (output logic [7:0] o1, output logic [7:0] o2);
  for (genvar i = 0; i < 2; i++) begin : g
    leaf l(.o());
  end
  if (1) begin : h
    leaf l(.o(o2));
  end
  leaf l0(.o(o1));
endmodule
