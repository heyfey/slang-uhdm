// § rootTdLeftoverStamp302
// r08: two modules each build their own value of the $root typedef
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module m1(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 1; c.b = 2; return c;
  endfunction
  localparam rc_t L = mk();
  assign o = L.a[0];
endmodule
module m2(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 5; c.b = 6; return c;
  endfunction
  localparam rc_t L = mk();
  assign o = L.b[0];
endmodule
module dut(output logic o, output logic q);
  m1 a (.o(o));
  m2 b (.o(q));
endmodule
