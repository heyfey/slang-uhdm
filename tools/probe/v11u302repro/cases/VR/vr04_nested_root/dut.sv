// § rootTdLeftoverStamp302
// vr04: a $root struct with a $root struct member, the builder writing the nested member
typedef struct packed { logic [7:0] x; logic [7:0] y; } in_t;
typedef struct packed { in_t u; int unsigned d; } rc_t;
module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.u.x = 1; c.u.y = 2; c.d = 7; return c;
  endfunction
  localparam rc_t L = mk();
  localparam int LD = L.d;
  assign o = 1'b0;
endmodule
