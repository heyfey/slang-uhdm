// § elabParamLeftoverOpRefUnnamed242
// (with § patLeftoverOpCopy242) The struct parameter overridden at the instance by another build call, and a holder passing it down to a child.
package cp;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; } ucfg_t;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; bit z; } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(2), a: 128'({64'h3, 64'h4})};
  localparam ucfg_t V = '{n: unsigned'(5), a: 128'({64'h7, 64'h8})};
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
module holder #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o, output logic p);
  child #(.C(C)) c (.o(o));
  assign p = 1'b1;
endmodule
module top (output logic o1, output logic o2, output logic o3, output logic o4);
  holder #(.C(cp::build(cp::V))) h1 (.o(o1), .p(o2));
  holder h2 (.o(o3), .p(o4));
endmodule
