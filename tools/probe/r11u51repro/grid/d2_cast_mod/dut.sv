// ROAD D, MODULE-BODY holder: the same four wrapper kinds.
package pk;
  typedef struct packed {
    int unsigned A; int unsigned B; int unsigned C; int unsigned D;
  } four_t;
endpackage
module dut (output logic [31:0] o);
  localparam pk::four_t Q = '{
      A: unsigned'(64), B: $unsigned(64), C: 32'(64), D: 64 };
  localparam int S1 = unsigned'(64);   // scalar holder, no pattern
  localparam int S2 = 64;
  assign o = Q.A | Q.B | Q.C | Q.D | S1 | S2;
endmodule
