// r10v96 arm 8 — CONSTANT FOLDS of moving-keyword casts.  The kind change has a
// downstream consequence (a folded constant's vpiSize/value are Compare-visible),
// so every moving keyword is folded in a parameter, a localparam, a case item, a
// range bound and a replication count, with negative and wide operands.
package v96p8;
  parameter int          P_INT  = integer'(7);
  parameter int          P_INTN = integer'(-7);
  parameter longint      P_LNG  = longint'(-7);
  parameter shortint     P_SHT  = shortint'(-7);
  parameter shortint     P_SHTW = shortint'(70000);
  parameter time         P_TIM  = time'(7);
  parameter realtime     P_RTM  = realtime'(7);
  parameter real         P_RL   = real'(7);
  parameter shortreal    P_SR   = shortreal'(7);
  parameter int          P_CTL  = int'(7);
  parameter byte         P_BYT  = byte'(7);
  parameter bit          P_BIT  = bit'(7);
endpackage

module v96m8;
  import v96p8::*;
  localparam int    L_INT = integer'(9);
  localparam longint L_LNG = longint'(9);
  localparam real   L_RL  = real'(9);
  logic [integer'(7):0] rb;
  logic [31:0] rep;
  int y;
  logic [15:0] q;
  initial begin
    case (q)
      integer'(1):  y = 1;
      longint'(2):  y = 2;
      shortint'(3): y = 3;
      time'(4):     y = 4;
      int'(5):      y = 5;
      default:      y = 6;
    endcase
    rep = {integer'(2){1'b1}};
    $display("%0d %0d %0d %0d %0f %0f %0d %0d %0d %0d %0d %0d %0d",
             P_INT, P_INTN, P_LNG, P_SHT, P_RL, P_SR, P_TIM, P_CTL, P_BYT,
             P_BIT, L_INT, L_LNG, y);
    $display("%0f %0d %0d", L_RL, rb, rep);
  end
endmodule
