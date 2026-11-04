// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 4});
  logic [CFG.DAT-1:0] data;
endinterface
module top();
  bus_if u();
endmodule
