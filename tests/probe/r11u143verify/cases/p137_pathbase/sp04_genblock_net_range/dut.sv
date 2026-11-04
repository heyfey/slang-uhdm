// § structParamPathBaseAtMember137
// case sp04: a member path in the range of a net declared inside a generate block
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 4, ADR: 2}) (output logic [3:0] o);
  if (1) begin : g
    logic [CFG.DAT-1:0] w;
    assign w = 4'h9;
    assign o = w;
  end
endmodule
