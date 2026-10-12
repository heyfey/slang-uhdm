// § rootTdLeftoverStamp302
// vr01: two localparams of one $root typedef built by two builders with different values
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module dut(output logic o);
  function automatic rc_t mk1();
    rc_t c; c.a = 3; c.b = 32; return c;
  endfunction
  function automatic rc_t mk2();
    rc_t c; c.a = 4; c.b = 42; return c;
  endfunction
  localparam rc_t L1 = mk1();
  localparam rc_t L2 = mk2();
  localparam int LA = L1.a + L2.a;
  assign o = 1'b0;
endmodule
