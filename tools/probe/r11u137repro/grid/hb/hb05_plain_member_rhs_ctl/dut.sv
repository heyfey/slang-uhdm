// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 4})(output int o);
  assign o = CFG.DAT;
endmodule
