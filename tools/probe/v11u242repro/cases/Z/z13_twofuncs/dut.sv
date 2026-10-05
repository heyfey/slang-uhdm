// § signCastLitLeftoverIsBodyOperand242
// Two holders built by two calls of the same function with different formals: the body's own literal stamped on both.
package cp;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; } ucfg_t;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; bit z; int unsigned k; } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(2), a: 128'({64'h3, 64'h4})};
  localparam ucfg_t V = '{n: unsigned'(4), a: 128'({64'h5, 64'h6})};
  function automatic cfg_t build(ucfg_t u);
    cfg_t r;
    r.n = u.n;
    r.a = u.a;
    r.z = u.n && u.a;
    r.k = unsigned'(2);
    return r;
  endfunction
endpackage
module h1 #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
module h2 #(parameter cp::cfg_t C = cp::build(cp::V)) (output logic o);
  assign o = 1'b1;
endmodule
module top (output logic o1, output logic o2);
  h1 a (.o(o1));
  h2 b (.o(o2));
endmodule
