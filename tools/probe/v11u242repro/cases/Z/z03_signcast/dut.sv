// § signCastLitLeftoverIsBodyOperand242
// unsigned' over several literals: unsized decimal, sized decimal, based hex, unbased unsized; beside a non-literal unsigned' (a parameter) and a plain literal.
package cp;
  localparam int K = 9;
  typedef struct packed { int unsigned n; logic [1:0][63:0] a; } ucfg_t;
  typedef struct packed {
    int unsigned n;
    logic [1:0][63:0] a;
    bit z;
    int unsigned k1;
    int unsigned k2;
    int unsigned k3;
    int unsigned k4;
    int unsigned k5;
    int k6;
  } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(2), a: 128'({64'h3, 64'h4})};
  function automatic cfg_t build(ucfg_t u);
    cfg_t r;
    r.n = u.n;
    r.a = u.a;
    r.z = u.n && u.a;
    r.k1 = unsigned'(4);
    r.k2 = unsigned'(32'd5);
    r.k3 = unsigned'('h6);
    r.k4 = unsigned'('1);
    r.k5 = unsigned'(K);
    r.k6 = 11;
    return r;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
