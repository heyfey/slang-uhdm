// § rootTdLeftoverStamp302
// r05: the $root-typed localparam overrides a child's parameter
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module kid #(parameter rc_t P = '{a: 0, b: 0}) (output logic o);
  assign o = P.a[0];
endmodule
module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 3; c.b = 4; return c;
  endfunction
  localparam rc_t L = mk();
  kid #(.P(L)) k0 (.o(o));
endmodule
