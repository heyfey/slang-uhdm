// § patLeftoverOpCopy242
// Two module parameters built from the same caller pattern, a localparam built from it too, two instances; the one-copy-per-element-per-stamp rule.
package cp;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; } ucfg_t;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; bit z; } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(2), a: 128'({64'h3, 64'h4})};
  function automatic cfg_t build(ucfg_t u);
    cfg_t r;
    r.n = u.n;
    r.a = u.a;
    r.z = u.n && u.a;
    return r;
  endfunction
endpackage
module holder #(parameter cp::cfg_t C = cp::build(cp::U), parameter cp::cfg_t D = cp::build(cp::U)) (output logic o);
  localparam cp::cfg_t L = cp::build(cp::U);
  assign o = 1'b0;
endmodule
module top (output logic o1, output logic o2);
  holder h1 (.o(o1));
  holder h2 (.o(o2));
endmodule
