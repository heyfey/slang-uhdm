// § elabParamLeftoverOpRefUnnamed242
// Two instances of a module whose parameter takes the struct a function builds, with a wide
// cast member: each elaborated copy holds its own leftover operation.
package cp;
  typedef struct packed {
    logic [1:0][63:0] base;
    int unsigned n;
    bit z;
  } cfg_t;
  localparam cfg_t U = '{base: 128'({64'h1, 64'h2}), n: 1, z: 0};
  function automatic cfg_t build(cfg_t c);
    cfg_t r;
    r.base = c.base;
    r.n = c.n;
    r.z = c.n && c.base;
    return r;
  endfunction
endpackage
module sub #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic [63:0] o);
  assign o = '0;
endmodule
module top (output logic [63:0] o1, output logic [63:0] o2);
  sub u1 (.o(o1));
  sub u2 (.o(o2));
endmodule
