// § rootTdLeftoverStamp302
// vr02: a module-local typedef shadows the $root typedef of the same name and members
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module m1(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam rc_t L = mk();
  assign o = L.a[0];
endmodule
module dut(output logic o, o1);
  typedef struct packed { int unsigned a; int unsigned b; } rc_t;
  function automatic rc_t mk();
    rc_t c; c.a = 5; c.b = 52; return c;
  endfunction
  localparam rc_t L = mk();
  m1 u1 (.o(o1));
  assign o = L.a[0];
endmodule
