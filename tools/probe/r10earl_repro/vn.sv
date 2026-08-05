// vn.sv — pass 11.  prim_cipher_pkg has both spellings of the same shape side
// by side: a PACKED 2-D array parameter initialised by a CONCATENATION
// (`PRINCE_SBOX4 = {4'h4, ...}`, line 23 — we agree with golden) and one
// initialised by an ASSIGNMENT PATTERN (`PRINCE_SHIFT_ROWS64 = '{4'hB, ...}`,
// line 33 — golden keeps an OPERATION in the ELABORATED package view where we
// fold a 64-bit constant).  3 Earlgrey heads (aes, aes_prng [AllModules] and
// prim_cipher_pkg itself [TopPackages]).
package vnp;
  parameter logic [3:0][3:0] CAT = {4'h1, 4'h2, 4'h3, 4'h4};   // concatenation
  parameter logic [3:0][3:0] PAT = '{4'h1, 4'h2, 4'h3, 4'h4};  // assign pattern
  parameter logic [7:0]      FLT = '{1'b1, 1'b0, 1'b1, 1'b0,
                                     1'b1, 1'b0, 1'b1, 1'b0}; // 1-D pattern
  parameter logic [7:0]      DFL = '{default: 1'b1};          // default setter
  parameter logic [3:0]      RPL = '{4{1'b1}};                // replication
endpackage

module vna (
  input  logic [1:0] s_i,
  output logic [3:0] o_c, o_p,
  output logic       o_f
);
  assign o_c = vnp::CAT[s_i];
  assign o_p = vnp::PAT[s_i];
  assign o_f = vnp::FLT[s_i];
endmodule

module vntop;
  logic [1:0] s;
  logic [3:0] c, p;
  logic f;
  vna u (.s_i(s), .o_c(c), .o_p(p), .o_f(f));
endmodule
