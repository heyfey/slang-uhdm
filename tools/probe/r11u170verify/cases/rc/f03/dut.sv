// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed { logic [3:0] base; logic [3:0] size; } cfg_t;
  parameter cfg_t LIT = '{base: 4'h1, size: 4'h8};
  function automatic logic hit(input logic [3:0] a, cfg_t C);
    return a >= C.base && a < C.base + C.size;
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (input logic [3:0] a, output logic h, output logic [7:0] o);
  assign o = CFG;
  assign h = p::hit(a, CFG);
endmodule
module top (input logic [3:0] a, output logic h, output logic [7:0] o); dut d(.a(a), .h(h), .o(o)); endmodule
