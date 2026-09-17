// v5 - ELEMENT KINDS the grid did not reach: integer/time/byte typedefs, a
// packed UNION element, a 2-state packed struct element, and a chain that ends
// two-state.
module dut #(parameter int unsigned D = 4) (output logic [1:0] o);
  typedef integer ig_t [D];
  typedef time    tm_t [D];
  typedef byte    by_t [D];
  typedef logic signed [1:0] sg_t;
  typedef sg_t    sa_t [D];
  typedef union packed { logic [1:0] a; logic [1:0] b; } up_t;
  typedef up_t    ua_t [D];
  typedef bit [1:0] b_t;
  typedef b_t     ba_t [D];
  typedef logic [1:0] v_t;
  typedef v_t     va_t [D];
  typedef va_t    vaa_t [2];   // unpacked typedef OF an unpacked typedef

  ig_t ig;  tm_t tm;  by_t by;  sa_t sa;  ua_t ua;  ba_t ba;  vaa_t vv;
  integer igd [D];             // control: no typedef
  assign o = ig[0][1:0] | tm[0][1:0] | by[0][1:0] | sa[0] | ua[0].a | ba[0] |
             vv[0][0];
endmodule
