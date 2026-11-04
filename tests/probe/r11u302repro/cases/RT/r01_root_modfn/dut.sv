// § rootTdLeftoverStamp302
// r01: a $root struct typedef, a module builder and a localparam (n11's shape)
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam rc_t L  = mk();
  localparam int  LA = L.a;
  assign o = 1'b0;
endmodule
