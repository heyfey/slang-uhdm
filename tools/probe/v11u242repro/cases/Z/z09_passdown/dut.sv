// § elabParamLeftoverOpRefUnnamed242
// (with § patLeftoverOpCopy242) The holder passes its struct parameter down to a child that has the same default.
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
module child #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
module top #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  child #(.C(C)) c (.o(o));
endmodule
