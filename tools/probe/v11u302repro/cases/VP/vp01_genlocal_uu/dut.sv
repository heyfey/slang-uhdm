// § modPatLeftoverCloneNoParent302
// vp01: the builder reads the module's pattern localparam and is called from a generate-block localparam
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
endpackage
module dut(output logic o);
  localparam pk::in_t UU = '{a: 11, b: 22};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  if (1) begin : g
    localparam pk::c_t L = mk();
    localparam pk::in_t MS = L.u;
  end
  assign o = 1'b0;
endmodule
