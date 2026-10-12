// § paramInitMemberSelFoldBaseSpan294
// function-assembled default in an interface
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; logic [7:0] m; } c_t;
  localparam c_t C = '{u: '{a: 1, b: 2}, d: 5, m: 8'h21};
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; c.m = 8'h5A; return c;
  endfunction
  localparam c_t F = mk();
endpackage
interface ifc #(parameter pk::c_t CFG = pk::F);
  localparam logic B = CFG.d[0];
  logic w;
  assign w = B;
endinterface
module dut(output logic [7:0] o); ifc i0 (); assign o = i0.w; endmodule
