// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] n; logic [7:0] base; } cfg_t;
  localparam cfg_t LIT = '{n: 4'd3, base: 8'h10};
  task automatic t1(input cfg_t C, output logic [3:0] r);
    r = C.n;
  endtask
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [3:0] n);
  assign n = CFG.n;
endmodule
