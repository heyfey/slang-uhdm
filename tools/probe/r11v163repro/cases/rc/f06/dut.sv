// § paramOpCloneRelocatedSpan163
package p;
  typedef union packed { logic [7:0] n; logic [7:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 8'd3};
  function automatic logic f1(cfg_t C, logic [7:0] a);
    return a >= C.base;
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [7:0] n);
  assign n = CFG.n;
endmodule
