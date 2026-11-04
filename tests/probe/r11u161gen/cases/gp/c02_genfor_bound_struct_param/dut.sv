// r11u161 gen path: gen-for bound reading a struct-parameter member (SEL)
package p;
  typedef struct packed { int unsigned N; int unsigned W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{N: 3, W: 2}) (input logic [3:0] a, output logic [3:0] o);
  for (genvar i = 0; i < CFG.N; i++) begin : g
    assign o[i] = a[i];
  end
  assign o[3] = 1'b0;
endmodule
