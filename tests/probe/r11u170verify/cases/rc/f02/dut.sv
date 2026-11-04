// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] base; logic [3:0] size; } cfg_t;
  parameter cfg_t LIT = '{base: 4'h2, size: 4'h4};
  function automatic void get_cfg(output cfg_t C);
    C = LIT;
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [7:0] o);
  assign o = CFG;
endmodule
module top (output logic [7:0] o); dut d(.o(o)); endmodule
