// § patLeftoverOpCopy242
// Residue: an INTERFACE instance holding the built struct parameter (golden stamps the
// interface parameter's copy, ours not: stage 1 on both binaries), beside two module holders.
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
interface ifc #(parameter cp::cfg_t C = cp::build(cp::U));
  logic [1:0] v;
endinterface
module sub #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic [63:0] o);
  assign o = '0;
endmodule
module top (output logic [63:0] o1, output logic [63:0] o2);
  ifc i0 ();
  sub u1 (.o(o1));
  sub u2 (.o(o2));
endmodule
