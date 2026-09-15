// v11u42 arm v5 — the CONCAT/REPL gate and its neighbours (must NOT fold).
package pv5;
  localparam int unsigned CATP = {2'b10, 2'b01};
  localparam int unsigned REPP = {2{2'b01}};
  localparam int unsigned CATN = {2'b10, 2'b01} + 0;  // concat INSIDE a binop init
  localparam int unsigned TERN = (1) ? 6 : 7;         // conditional init
  localparam int unsigned CALL = $clog2(64);          // sysfunc init
  localparam int unsigned CAST = int'(6);             // cast init
  localparam int unsigned LP   = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage

module v5 (input logic [19:0] w20, output logic [63:0] o);
  pv5::s_t v;
  assign v = w20;
  assign o[0] = v.m[pv5::CATP-1];   // c01 concat-init  (golden keeps the name)
  assign o[1] = v.m[pv5::REPP-1];   // c02 repl-init    (golden keeps the name)
  assign o[2] = v.m[pv5::CATN-1];   // c03 concat inside a binop init
  assign o[3] = v.m[pv5::TERN-1];   // c04 conditional init
  assign o[4] = v.m[pv5::CALL-1];   // c05 sysfunc init
  assign o[5] = v.m[pv5::CAST-1];   // c06 cast init
  assign o[6] = v.m[pv5::CATP];     // c07 BARE concat-init read
  assign o[7] = v.m[pv5::LP-1];     // c08 control: plain init folds
endmodule
