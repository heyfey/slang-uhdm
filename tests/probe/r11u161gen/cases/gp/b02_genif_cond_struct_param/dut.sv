// r11u161 gen path: gen-if condition reading a struct-parameter member (SEL)
package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{A: 1, B: 2}) (input logic a, output logic o);
  if (CFG.A == 1) begin : g
    assign o = a;
  end else begin : h
    assign o = ~a;
  end
endmodule
