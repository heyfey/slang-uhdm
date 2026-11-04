// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] n; logic [7:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 4'd3, base: 8'h10};
  function automatic logic f1(cfg_t C, logic [7:0] a);
    return a >= C.base;
  endfunction
  function automatic logic f2(logic [7:0] a, cfg_t D);
    return a < D.base;
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (input logic [7:0] a, output logic o, output logic [3:0] n);
  assign o = p::f1(CFG, a) & p::f2(a, CFG);
  assign n = CFG.n;
endmodule
