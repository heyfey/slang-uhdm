// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int N; int W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{N: 3, W: 4})(output logic [3:0] o);
  for (genvar i = 0; i < CFG.N; i++) begin : g
    assign o[i] = 1'b1;
  end
endmodule
