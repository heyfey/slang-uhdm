// r10earl105 g5 — the CORPUS SHAPE: `int`-typed parameters (whose elaborated
// param_assign Rhs carries an int_typespec) read BARE from a TOP-LEVEL
// loop-generate cont_assign of a CHILD instance, in every operand position.
// This is tlul_socket_m1's IDW / STIDW and pinmux's MioPeriphHasSleepMode.
module g5_leaf105 #(
  parameter int IDW   = 8,
  parameter int STIDW = 2
) (
  input  logic [31:0] sig,
  output logic [63:0] z
);
  localparam int         MODI  = 4;
  localparam logic [7:0] MODR  = {8{1'b1}};   // a replication fold: LOC-LESS int_typespec

  for (genvar i = 0; i < 2; i++) begin : gen_l
    logic [63:0] p1, p2, p3, p4, p5, p6, p7;
    assign p1 = IDW ^ sig;                       // plain binary operand
    assign p2 = {IDW, STIDW} ^ sig;              // concat operands
    assign p3 = $bits(p3)'({MODR, 1'b1, 1'b1});  // the head's own shape
    assign p4 = sig[IDW];                        // a bit-select index
    assign p5 = sig[IDW +: 2];                   // an indexed-part-select base
    assign p6 = {MODI{1'b1}} ^ sig;              // a replication count
    assign p7 = (IDW > STIDW) ? sig : 32'b0;     // both sides of a comparison
  end
  assign z = 64'b0;
endmodule

module g5_int105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  g5_leaf105 #(.IDW(8), .STIDW(2)) u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
