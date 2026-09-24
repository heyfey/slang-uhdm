// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; } in_t;
  typedef struct packed { in_t I; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{I: '{W: 8}, ADR: 4})();
  logic [CFG.I.W-1:0] data;
endmodule
