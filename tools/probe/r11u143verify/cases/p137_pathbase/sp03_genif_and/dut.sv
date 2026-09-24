// § structParamPathBaseAtMember137
// case sp03: two member paths joined by && in a generate-if condition
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 3}) (output logic [3:0] o);
  if (CFG.DAT > 4 && CFG.ADR < 8) begin : g
    assign o = 4'd1;
  end else begin : h
    assign o = 4'd2;
  end
endmodule
