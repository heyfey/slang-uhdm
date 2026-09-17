// r11u58 xd6 — THE EXCLUSION FACES.  Three package pattern parameters in ONE
// package: one read ONLY as a module parameter default (`ff_dead_both_branches`
// / `iface_*` shape), one read ONLY by a member select, one never read at all.
// NO const-function call anywhere.  PREDICT: NOT ONE element is re-stamped;
// the elaborated package listing equals the definition listing, cell for cell.
package pk;
  typedef struct packed {
    int unsigned A;   // 64            -> stays 64
    int unsigned B;   // unsigned'(64) -> stays 64
    logic [7:0]  D;   // 32'(5)        -> stays 32
    logic [15:0] F;   // 8'(3)         -> stays 8
  } u_t;
  localparam u_t P1 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };  // param-default read
  localparam u_t P2 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };  // member-select read
  localparam u_t P3 = '{ A: 64, B: unsigned'(64), D: 32'(5), F: 8'(3) };  // NEVER read
endpackage
module dut #(parameter pk::u_t Q = pk::P1) (output logic [31:0] o);
  localparam int unsigned Z = pk::P2.A;
  assign o = Q.A + Z;
endmodule
