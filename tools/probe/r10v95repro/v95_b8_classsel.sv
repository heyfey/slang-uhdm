// r10v95 arm b8 — CLASS property shapes: own vs inherited vs static vs
// handle-qualified, this./super., select-then-member and member-then-select.
package p8;
  typedef struct packed { logic [11:0] hi; logic [3:0] lo; } s16_t;
  class Base8;
    logic [22:0] b_vec;
    byte         b_dyn [];
  endclass
  class Der8 extends Base8;
    logic [13:0] d_vec;
    byte         d_fix [5];
    s16_t        d_sp;
    s16_t        d_spa [2];
    byte         d_q [$];
    int          d_as [string];
    real         d_re;
    shortreal    d_sr;
    realtime     d_rt;
    time         d_tm;
    string       d_st;
    chandle      d_ch;
    Base8        d_h;
    static int   s_cnt;
    static logic [9:0] s_vec;
    function int probe(int i);
      Der8 other;
      int a;
      a  = $bits(d_vec[2]);
      a += $bits(d_fix[i]);
      a += $bits(d_fix[i][3:0]);
      a += $bits(d_q[0]);
      a += $bits(d_as["z"]);
      a += $bits(d_sp);
      a += $bits(d_sp.hi);
      a += $bits(d_spa[1].lo);
      a += $bits(d_spa[1]);
      a += $bits(this.d_vec[5]);
      a += $bits(b_vec[1]);
      a += $bits(b_dyn[0]);
      a += $bits(super.b_vec[3]);
      a += $bits(other.d_vec[2]);
      a += $bits(d_h.b_vec[4]);
      a += $bits(s_vec[1]);
      a += $bits(d_re);
      a += $bits(d_sr);
      a += $bits(d_rt);
      a += $bits(d_tm);
      a += $bits(d_st);
      a += 0;
      a += $bits(d_h);
      return a;
    endfunction
  endclass
endpackage
module b8;
  p8::Der8 dd;
  int o;
  initial o = dd.probe(1);
endmodule
