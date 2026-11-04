// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 4})(output logic o);
  if (CFG.DAT > 4) begin : g
    assign o = 1'b1;
  end else begin : h
    assign o = 1'b0;
  end
endmodule
