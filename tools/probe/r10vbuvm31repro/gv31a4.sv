// v31a4 — POSITION controls: assignment patterns OUTSIDE a declaration
// initializer, plus multi-instance elaboration of the law's own cells.
package v31p4;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } ps4_t;
  function automatic int f4(int q[$]); return q.size(); endfunction
  function automatic int g4(); int r[] = '{1, 2}; return r.size(); endfunction
endpackage

module v31sub #(parameter int N = 1) (input logic clk);
  int  sd[]        = '{1, 2, 3};
  int  saa[string] = '{default: 0};
  int  sq[$]       = '{4, 5};
  class v31sc;
    protected int p_aa[string] = '{default: 0};
              int p_d[]        = '{1, 2};
  endclass
  v31sc h = new();
  initial $display(N, sd.size(), saa.size(), sq.size(), h.p_d.size());
endmodule

module v31m4 (input logic clk);
  import v31p4::*;
  int  ad[];
  int  aaa[string];
  int  aq[$];
  ps4_t pk;
  int  fx[3];
  logic [7:0] cc;

  v31sub #(1) i1 (.clk(clk));
  v31sub #(2) i2 (.clk(clk));
  v31sub #(3) i3 (.clk(clk));

  assign cc = {4'h1, 4'h2};

  initial begin
    ad  = '{1, 2, 3};          // statement Rhs, not a declaration
    aaa = '{default: 0};
    aq  = '{4, 5};
    fx  = '{1, 2, 3};
    pk  = '{default: 0};
    $display(f4('{7, 8}));     // call argument
    $display(v31p4::g4());
    if (fx[0] == 1) $display("eq");
    $display({fx[0], fx[1]});
  end

  function automatic int r4();
    int t[] = '{9, 10};
    return t.size();
  endfunction
  initial $display(r4());
endmodule
