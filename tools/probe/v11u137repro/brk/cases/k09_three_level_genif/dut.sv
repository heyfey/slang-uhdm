// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int W; } in_t;
  typedef struct packed { in_t I; int X; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{I: '{W: 4}, X: 1})(output logic o);
  if (CFG.I.W > 2) begin : g
    assign o = 1'b1;
  end else begin : h
    assign o = 1'b0;
  end
endmodule
