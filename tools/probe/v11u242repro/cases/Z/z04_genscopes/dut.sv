// § s2CloneGenScopeInst242
// (with § patLeftoverOpCopy242) Holders in a for-generate (two iterations), in a case-generate, and in a nested if-generate two levels down.
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
module leaf #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
module top #(parameter int M = 1) (output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    leaf u (.o(o[i]));
  end
  case (M)
    1: begin : gc
      leaf u (.o(o[2]));
    end
    default: begin : gd
      assign o[2] = 1'b1;
    end
  endcase
  if (M > 0) begin : g1
    if (M < 5) begin : g2
      leaf u (.o(o[3]));
    end
  end
endmodule
