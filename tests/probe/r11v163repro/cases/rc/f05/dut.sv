// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] n; logic [7:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 4'd3, base: 8'h10};
  function automatic logic f1(input cfg_t C, input logic [7:0] a);
    return a >= C.base;
  endfunction
endpackage
module dut import p::*; #(parameter cfg_t CFG = LIT) (output logic [3:0] n);
  assign n = CFG.n;
endmodule
