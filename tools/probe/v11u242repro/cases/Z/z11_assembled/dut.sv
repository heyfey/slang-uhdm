// § signCastLitLeftoverIsBodyOperand242
// (with § patLeftoverOpCopy242) The built struct assembles (no unreducible member): unsigned'(2) and a wide cast member.
package cp;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; } ucfg_t;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; int unsigned k; } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(2), a: 128'({64'h3, 64'h4})};
  function automatic cfg_t build(ucfg_t u);
    cfg_t r;
    r.n = u.n;
    r.a = u.a;
    r.k = unsigned'(2);
    return r;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
