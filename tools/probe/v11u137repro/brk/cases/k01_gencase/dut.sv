// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int MODE; int W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{MODE: 1, W: 4})(output logic o);
  case (CFG.MODE)
    1: begin : a assign o = 1'b1; end
    default: begin : b assign o = 1'b0; end
  endcase
endmodule
