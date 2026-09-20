// r11u68 arm b5 — THE POST-BAIL SIZE TABLE, second cut: the remaining
// operator arms, the NAME arm across declared widths, and the literal forms.
// Operand 0 is `-1`, a guaranteed bail, so every operand after it carries the
// size `reduceExpr` gave it, never the 8-bit member width.
package qf;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  localparam PU = 6;
  localparam byte PB = 8'sd12;
  localparam shortint PS = 16'sd12;
  localparam longint PL = 64'sd12;
  localparam bit [3:0] PBIT = 4'd3;
  localparam logic [95:0] P96 = 96'd7;
  localparam logic [7:0] P8 = 8'd12;
  typedef enum logic [7:0] { E_A = 8'd9 } e_t;
  typedef struct packed {
    logic [7:0] b;
    logic [7:0] band;
    logic [7:0] bor;
    logic [7:0] shr;
    logic [7:0] ashr;
    logic [7:0] dvd;
    logic [7:0] mod;
    logic [7:0] pw;
    logic [7:0] pb;
    logic [7:0] ps;
    logic [7:0] pl;
    logic [7:0] pu;
    logic [7:0] pbit;
    logic [7:0] p96;
    logic [7:0] negpu;
    logic [7:0] negp8;
    logic [7:0] addpu;
    logic [7:0] addp8;
    logic [7:0] addp8l;
    logic [7:0] subk;
    logic [7:0] strl;
    logic [7:0] enumm;
    logic [7:0] unsz;
    logic [7:0] repl;
    logic [7:0] cat;
    logic [7:0] cmpg;
    logic [7:0] l4d;
    logic [7:0] l1b;
    logic [7:0] l96;
    logic [7:0] bits;
  } ft_t;
  localparam ft_t BAILED = '{b: -1, band: KU & 3, bor: KU | 8, shr: K >> 1, ashr: K >>> 1, dvd: K / 2, mod: K % 4, pw: K ** 2, pb: PB, ps: PS, pl: PL, pu: PU, pbit: PBIT, p96: P96, negpu: -PU, negp8: -P8, addpu: PU + 1, addp8: P8 + P8, addp8l: P8 + 1, subk: K - 1, strl: "abc", enumm: E_A, unsz: '1, repl: {2{4'd3}}, cat: {8'd1, 8'd2}, cmpg: K > 2, l4d: 4'd3, l1b: 1'b1, l96: 96'h1, bits: $bits(K)};
endpackage
module b5_redsz68 #(parameter qf::ft_t CB = qf::BAILED)
                   (output logic [31:0] yb);
  assign yb = CB.b + CB.band + CB.bor + CB.shr + CB.ashr + CB.dvd + CB.mod + CB.pw + CB.pb + CB.ps + CB.pl + CB.pu + CB.pbit + CB.p96 + CB.negpu + CB.negp8 + CB.addpu + CB.addp8 + CB.addp8l + CB.subk + CB.strl + CB.enumm + CB.unsz + CB.repl + CB.cat + CB.cmpg + CB.l4d + CB.l1b + CB.l96 + CB.bits;
endmodule
