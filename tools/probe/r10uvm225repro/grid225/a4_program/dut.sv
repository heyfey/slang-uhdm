// r10uvm225 arm a4_program — the third holder writeNets serves.  The
// interface arm of the producer is gated `parent->UhdmType() ==
// uhdminterface_inst`, so a PROGRAM should get none either.
class Cp225;
  int x;
endclass

typedef logic [7:0] tvp225_t;

program prg225_kinds();
  Cp225       p_dyncls225 [];
  tvp225_t    p_dyntv225  [];
  int         p_fixint225 [2];
  int         p_qint225   [$];
  tvp225_t    p_astv225   [string];
endprogram

module top225_prg(); endmodule
