// § elabCastKeyBindsDefNet286 — a module-local typedef and a parameter-port list
module leaf #(parameter int W = 4) (output logic [7:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } p2_t;
  localparam p2_t A = p2_t'{a: 4'd5, b: 4'd6};
  assign o = A;
endmodule
module top (output logic [7:0] o1, output logic [7:0] o2);
  leaf u1(.o(o1));
  leaf #(.W(8)) u2(.o(o2));
endmodule
