// r11u34 grid g5 — the ONLY scoped reference is inside a PARAMETER
// DECLARATION (the landed hasScopedPkgRef caveat).
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:2] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
endpackage
module g5 #(parameter q::enc_t [0:2] CP = q::PA,
            parameter logic [1:0][1:0][3:0] CV = q::PV)
           (output logic [31:0] o);
  assign o = CP[0].e + CV[0][0];
endmodule
