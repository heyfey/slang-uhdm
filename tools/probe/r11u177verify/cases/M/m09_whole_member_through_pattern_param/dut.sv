// § memLeftSliceUnlocated169 § memLeftFormalArgLoc169
package pk;
  typedef struct packed { int unsigned s; int unsigned d; } u_t;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  localparam u_t UC = '{s: 5, d: 6};
  function automatic c_t build(u_t uu);
    c_t c;
    c.a = uu.s;
    c.b = uu.d * 4;
    return c;
  endfunction
  localparam c_t C = build(UC);
endpackage
module top #(parameter pk::c_t CFG = pk::C) (output logic [CFG.b-1:0] o, output logic [CFG.a-1:0] q);
endmodule
