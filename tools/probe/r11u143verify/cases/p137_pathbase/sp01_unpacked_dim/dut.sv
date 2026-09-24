// § structParamPathBaseAtMember137
// case sp01: a struct-parameter member path in an unpacked dimension
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 4, ADR: 2}) (output logic o);
  logic m [CFG.DAT];
  assign m[0] = 1'b1;
  assign o = m[0];
endmodule
