// § memLeftSliceUnlocated169 § memLeftFormalArgLoc169
package pk;
  typedef struct packed { int unsigned s; int unsigned d; } u_t;
  typedef struct packed { int unsigned a; int unsigned b; int unsigned e; } c_t;
  function automatic c_t build(u_t uu);
    c_t c;
    c.a = uu.s;
    c.b = uu.d + 1;
    c.e = 5;
    return c;
  endfunction
  localparam c_t C = build('{s: 3, d: 32});
endpackage
module top #(parameter pk::c_t CFG = pk::C) (output logic [CFG.b-1:0] o, output logic [CFG.a-1:0] q);
endmodule
