// r11u34 grid g2 — the corpus shape: the packed-array-of-struct package
// parameter is read ONLY UNQUALIFIED, from inside the package's own function
// (`ENC[i].e`).  No `q::ENC` anywhere.
package q;
  localparam int unsigned NF = 3;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:NF-1] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam enc_t [NF-1:0] PD = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
  localparam enc_t PU [0:1] = '{'{4, 3}, '{3, 2}};
  function automatic int unsigned rd(int unsigned i);
    return PA[i].e + PD[i].m + PV[0][0] + PU[0].e;
  endfunction
endpackage

module g2 (output logic [31:0] o);
  assign o = q::rd(0);
endmodule
