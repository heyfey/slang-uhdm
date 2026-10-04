// § hpSelIdxPkgFoldTsOwner236 — package index member paths in a task, a function, a for-generate and an if-generate
package pk;
  localparam int N = 2;
  typedef struct packed { logic q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module top import pk::*; #(parameter bit G = 1) (input logic a, output logic o, output logic o2, output logic [1:0] o3);
  r_t [N:0] rc;
  r_t [N:0] rt;
  function automatic logic rd(r_t [N:0] x);
    return x[N].base.q;
  endfunction
  task automatic wr(output r_t [N:0] x);
    x = '0;
    x[N].size.q = 1'b1;
  endtask
  assign rc[N-1:0] = '0;
  assign rc[N].base.q = a;
  assign rc[N].size.q = ~a;
  always_comb wr(rt);
  assign o = rd(rc) | rt[N].size.q;
  for (genvar i = 0; i < 2; i++) begin : gl
    assign o3[i] = rc[N].base.q;
  end
  if (G) begin : gi
    assign o2 = rc[N].size.q;
  end
endmodule
