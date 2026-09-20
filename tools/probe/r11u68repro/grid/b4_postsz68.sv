// r11u68 arm b4 — THE POST-BAIL SIZE TABLE.  Operand 0 (`bail`) is `-1`,
// whose reduce is `INT:-1` and whose `get_uvalue` refuses, so the walk returns
// at operand 0 and EVERY operand after it keeps the size `reduceExpr` gave it.
// Every member below is 8 bits wide, so the member width the walk would have
// stamped is distinguishable from every answer in the reduce's own size table.
// `ctl_*` is the SAME struct with a NON-bailing operand 0, so each row's two
// halves read "stamped" against "own size" side by side.
package qe;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  localparam logic [7:0] P8 = 8'd12;
  typedef enum logic [7:0] { E_A = 8'd9 } e_t;
  function automatic int f_id(int x); return x; endfunction
  typedef struct packed {
    logic [7:0] b;
    logic [7:0] dec;
    logic [7:0] kadd;
    logic [7:0] kaddn;
    logic [7:0] kmul;
    logic [7:0] ksub;
    logic [7:0] negk;
    logic [7:0] bnot;
    logic [7:0] shbig;
    logic [7:0] tern;
    logic [7:0] cint;
    logic [7:0] clg;
    logic [7:0] cat;
    logic [7:0] cmpg;
    logic [7:0] lit8d;
    logic [7:0] lit8h;
    logic [7:0] lit8b;
    logic [7:0] lit4h;
    logic [7:0] lit16h;
    logic [7:0] enumm;
    logic [7:0] unsz;
    logic [7:0] nameK;
    logic [7:0] nameU;
    logic [7:0] name8;
    logic [7:0] repl;
    logic [7:0] fcall;
  } et_t;
  localparam et_t BAILED = '{b: -1, dec: 3, kadd: K + 1, kaddn: K + KU, kmul: K * 2, ksub: 9 - 2, negk: -K, bnot: ~KU, shbig: KU << 40, tern: K ? 3 : 4, cint: int'(K), clg: $clog2(40), cat: {8'd1, 8'd2}, cmpg: K > 2, lit8d: 8'd42, lit8h: 8'hA5, lit8b: 8'b10100101, lit4h: 4'hA, lit16h: 16'hBEEF, enumm: E_A, unsz: '1, nameK: K, nameU: KU, name8: P8, repl: {2{4'd3}}, fcall: f_id(6)};
  localparam et_t NOBAIL = '{b: 1, dec: 3, kadd: K + 1, kaddn: K + KU, kmul: K * 2, ksub: 9 - 2, negk: -K, bnot: ~KU, shbig: KU << 40, tern: K ? 3 : 4, cint: int'(K), clg: $clog2(40), cat: {8'd1, 8'd2}, cmpg: K > 2, lit8d: 8'd42, lit8h: 8'hA5, lit8b: 8'b10100101, lit4h: 4'hA, lit16h: 16'hBEEF, enumm: E_A, unsz: '1, nameK: K, nameU: KU, name8: P8, repl: {2{4'd3}}, fcall: f_id(6)};
endpackage
module b4_postsz68 #(parameter qe::et_t CB = qe::BAILED,
                     parameter qe::et_t CN = qe::NOBAIL)
                    (output logic [31:0] yb, output logic [31:0] yn);
  assign yb = CB.b + CB.dec + CB.kadd + CB.kaddn + CB.kmul + CB.ksub + CB.negk + CB.bnot + CB.shbig + CB.tern + CB.cint + CB.clg + CB.cat + CB.cmpg + CB.lit8d + CB.lit8h + CB.lit8b + CB.lit4h + CB.lit16h + CB.enumm + CB.unsz + CB.nameK + CB.nameU + CB.name8 + CB.repl + CB.fcall;
  assign yn = CN.b + CN.dec + CN.kadd + CN.kaddn + CN.kmul + CN.ksub + CN.negk + CN.bnot + CN.shbig + CN.tern + CN.cint + CN.clg + CN.cat + CN.cmpg + CN.lit8d + CN.lit8h + CN.lit8b + CN.lit4h + CN.lit16h + CN.enumm + CN.unsz + CN.nameK + CN.nameU + CN.name8 + CN.repl + CN.fcall;
endmodule
