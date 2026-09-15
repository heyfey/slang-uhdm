// v11u34 v4 — the only `q::PA` read is an INSTANCE PARAMETER OVERRIDE.
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module sub #(parameter int unsigned W = 1, parameter int unsigned V = 1)
           (output logic [31:0] o);
  assign o = W + V;
endmodule
module v4 (output logic [31:0] o);
  sub #(.W(q::PA[0].e), .V(q::PV[0][0])) u (.o(o));
endmodule
