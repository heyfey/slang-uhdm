// § structParamPathBaseAtMember137
// case sp02: a struct-parameter member path in a module typedef's range
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 6, ADR: 2}) (output logic [5:0] o);
  typedef logic [CFG.DAT-1:0] d_t;
  d_t v;
  assign v = '1;
  assign o = v;
endmodule
