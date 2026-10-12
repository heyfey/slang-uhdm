// § rootTdLeftoverStamp302
// vr05: the $root typed localparam beside a variable of the same type and a port of it
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module kid(input rc_t pi, output logic o);
  assign o = pi.a[0];
endmodule
module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam rc_t L = mk();
  rc_t v;
  assign v = L;
  kid u (.pi(v), .o(o));
endmodule
