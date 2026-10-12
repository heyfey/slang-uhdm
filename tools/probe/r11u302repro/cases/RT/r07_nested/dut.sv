// § rootTdLeftoverStamp302
// r07: a nested $root struct
typedef struct packed { int unsigned x; int unsigned y; } in_t;
typedef struct packed { in_t u; int unsigned d; } rc_t;
module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.u.x = 1; c.u.y = 2; c.d = 3; return c;
  endfunction
  localparam rc_t L = mk();
  localparam in_t U = L.u;
  assign o = 1'b0;
endmodule
