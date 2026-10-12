// § paramInitMemberSelFoldBaseSpan294
// an interface localparam
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; logic [7:0] v; } c_t;
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; c.v = 8'h5A; return c;
  endfunction
  localparam c_t C = mk();
endpackage
interface ifc #(parameter pk::c_t CFG = pk::C) ();
  localparam int B = CFG.d[2];
  logic s;
  assign s = ^{B, 1'b0};
endinterface
module dut(output logic o); ifc i0 (); assign o = i0.s; endmodule
