// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] n; logic [7:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 4'd3, base: 8'h10};
  function automatic cfg_t mk(cfg_t C);
    return C;
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [3:0] n);
  assign n = CFG.n;
endmodule
