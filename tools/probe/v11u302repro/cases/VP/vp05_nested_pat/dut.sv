// § modPatLeftoverCloneNoParent302
// vp05: a nested pattern localparam (struct of struct) and a default-keyed pattern read by the builder
package pk;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } lo_t;
  typedef struct packed { lo_t l; logic [7:0] z; } in_t;
  typedef struct packed { in_t u; in_t v; } c_t;
endpackage
module dut(output logic o);
  localparam pk::in_t UU = '{l: '{x: 1, y: 2}, z: 3};
  localparam pk::in_t VV = '{default: 0};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.v = VV; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam pk::in_t MS = L.u;
  assign o = 1'b0;
endmodule
