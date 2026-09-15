// r11u34 grid g1 — a NESTED-operand assignment pattern in a PACKAGE listing
// vs the same shape in a MODULE.  Every arm is read by a scoped `q::` name so
// the package's elaborated listing is reduced the same way the corpus row is.
package q;
  localparam int unsigned NF = 3;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  // ascending packed array of packed struct, nested pattern operands
  localparam enc_t [0:NF-1] PA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  // descending twin
  localparam enc_t [NF-1:0] PD = '{'{4, 3}, '{3, 2}, '{2, 1}};
  // packed 3-D vector, nested pattern operands
  localparam logic [1:0][1:0][3:0] PV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
  // flat (constant) operands — the already-landed pkgVecPatternNoSize face
  localparam logic [3:0][3:0] PF = '{4'h1, 4'h2, 4'h3, 4'h4};
  // unpacked array of packed struct, nested operands
  localparam enc_t PU [0:1] = '{'{4, 3}, '{3, 2}};
endpackage

module g1 (output logic [31:0] o);
  // MODULE twins (the positive control: the stamp must SURVIVE here)
  localparam q::enc_t [0:2] MA = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam q::enc_t [2:0] MD = '{'{4, 3}, '{3, 2}, '{2, 1}};
  localparam logic [1:0][1:0][3:0] MV = '{'{4'h1, 4'h2}, '{4'h3, 4'h4}};
  localparam logic [3:0][3:0] MF = '{4'h1, 4'h2, 4'h3, 4'h4};
  localparam q::enc_t MU [0:1] = '{'{4, 3}, '{3, 2}};
  assign o = q::PA[0].e + q::PD[0].e + q::PV[0][0] + q::PF[0]
           + q::PU[0].e + MA[0].e + MD[0].e + MV[0][0] + MF[0] + MU[0].e;
endmodule
