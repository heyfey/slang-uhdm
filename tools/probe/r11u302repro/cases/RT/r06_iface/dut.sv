// § rootTdLeftoverStamp302
// r06: an interface holder
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
interface ifc;
  function automatic rc_t mk();
    rc_t c; c.a = 9; c.b = 10; return c;
  endfunction
  localparam rc_t L = mk();
  logic s;
endinterface
module dut(output logic o);
  ifc u();
  assign o = u.s;
endmodule
