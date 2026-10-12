// § leftoverSlotSoleWriter302v
// vq07: vq03 with the two localparams declared in the other order (the unqualified builder first)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage
module dut(output logic o);
  import pk::UU;
  function automatic pk::c_t mk();
    pk::c_t c; c.u = pk::UU; c.d = 64; return c;
  endfunction
  function automatic pk::c_t mk2();
    pk::c_t c; c.u = UU; c.d = 65; return c;
  endfunction
  localparam pk::c_t L2 = mk2();
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
