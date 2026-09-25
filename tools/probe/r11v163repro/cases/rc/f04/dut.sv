// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] n; logic [7:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 4'd3, base: 8'h10};
  function automatic logic f1(cfg_t C, logic [7:0] a);
    return a >= C.base;
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [3:0] n);
  assign n = CFG.n;
endmodule
module top(output logic [3:0] n1, n2);
  dut a(.n(n1));
  dut #(.CFG('{n: 4'd7, base: 8'h20})) b(.n(n2));
endmodule
