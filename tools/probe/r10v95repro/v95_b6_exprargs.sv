// r10v95 arm b6 — argument kinds that are EXPRESSIONS: concats, casts, calls,
// parameters, replication, ternary, streams, >64-bit, X/Z literals.
module b6;
  parameter int P1 = 6;
  localparam int Q1 = 40;
  logic [P1-1:0]  pw;
  logic [Q1-1:0]  qw;
  logic [79:0]    big80;
  logic [127:0]   big128;
  byte            ba [3];
  byte            bd [];
  logic [7:0]     be;
  int             y [24];
  function automatic int f6(input int a); return a; endfunction
  initial begin
    y[0]  = $bits({pw, qw});
    y[1]  = $bits({2{pw}});
    y[2]  = $bits(8'(pw));
    y[3]  = $bits(int'(pw));
    y[4]  = $bits(f6(3));
    y[5]  = $bits(P1);
    y[6]  = $bits(Q1);
    y[7]  = $bits(big80);
    y[8]  = $bits(big128);
    y[9]  = $bits(big128[100:3]);
    y[10] = $bits(8'bxxxx_zzzz);
    y[11] = $bits(8'hAB);
    y[12] = $bits(bd[0] & be);
    y[13] = $bits(ba[1] & be);
    y[14] = $bits(~pw);
    y[15] = $bits(pw ? qw : qw);
    y[16] = $bits(ba);
    y[17] = $bits(bd[0] + 1);
    y[18] = $bits(ba[0][3:1]);
    y[19] = $bits($signed(pw));
  end
endmodule
