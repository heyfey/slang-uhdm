// v11u42 arm v9 — the CONCAT/REPLICATION index context: which SPELLING golden
// gives a folded package parameter there (decimal, or the init's own base?).
package pz9;
  localparam logic [3:0]  HEX  = 4'hA;
  localparam int unsigned DEC  = 10;
  localparam logic [1:0]  CNT  = 2'd2;
  localparam logic [1:0]  SP   = 2'd1;
  typedef struct packed { logic [31:0] w; } s_t;
endpackage

module v9 (input logic [3:0] k, output logic [63:0] o);
  pz9::s_t q;
  assign q = 32'hDEAD_BEEF;
  assign o[0] = q.w[{1'b1, pz9::SP}];        // c01 sized-decimal init in a concat
  assign o[1] = q.w[{1'b0, pz9::HEX}];       // c02 hex init in a concat
  assign o[2] = q.w[{1'b0, pz9::DEC[3:0]}];  // c03 part-select of a decimal init
  assign o[3] = q.w[{pz9::CNT{1'b1}}];       // c04 replication COUNT
  assign o[4] = q.w[{1'b0, pz9::HEX} + 1];   // c05 concat inside a binop
  assign o[5] = q.w[pz9::HEX - 1];           // c06 control: binop, hex init
  assign o[6] = q.w[{1'b0, k[0], pz9::HEX}]; // c07 hex in third position
endmodule
