// § memLeftSliceUnlocated169
package pk;
  typedef struct packed { int unsigned s; int unsigned d; } u_t;
  typedef struct packed { u_t u; int unsigned der; } c_t;
  function automatic u_t mku();
    u_t c;
    c.s = 3;
    c.d = 32;
    return c;
  endfunction
  function automatic c_t build(u_t uu);
    c_t c;
    c.u = uu;
    c.der = uu.d * 2;
    return c;
  endfunction
  localparam u_t UC = mku();
  localparam c_t C = build(UC);
endpackage
module top #(parameter pk::c_t CFG = pk::C) (output logic [CFG.der-1:0] o);

endmodule
