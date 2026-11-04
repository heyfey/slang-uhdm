// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 4})(input logic [CFG.DAT-1:0] i, output logic [CFG.ADR-1:0] o);
  assign o = i[CFG.ADR-1:0];
endmodule
