// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int E; int N; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{E: 1, N: 2})(output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : l
    if (CFG.E == 1) begin : a
      assign o[i] = 1'b1;
    end else begin : b
      assign o[i] = 1'b0;
    end
  end
endmodule
