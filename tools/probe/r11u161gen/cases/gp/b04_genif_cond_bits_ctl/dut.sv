// r11u161 gen path CONTROL: gen-if condition with the path as a call argument ($bits) (CFC, expected unchanged)
package p;
  typedef struct packed { logic [3:0] A; int unsigned B; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{A: 4'd1, B: 2}) (input logic a, output logic o);
  if ($bits(CFG.A) == 4) begin : g
    assign o = a;
  end else begin : h
    assign o = ~a;
  end
endmodule
