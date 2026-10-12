// § rootTdLeftoverStamp302
// vr03: a $root typed localparam built in an interface and in the module that instantiates it
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
interface ifc;
  function automatic rc_t mki();
    rc_t c; c.a = 6; c.b = 62; return c;
  endfunction
  localparam rc_t IL = mki();
  logic s;
endinterface
module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam rc_t L = mk();
  ifc i0 ();
  assign o = i0.s ^ L.a[0];
endmodule
