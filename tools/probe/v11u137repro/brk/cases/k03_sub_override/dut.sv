// § structParamPathBaseAtMember137
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module sub #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 4})(output logic o);
  logic [CFG.DAT-1:0] d;
  if (CFG.ADR > 2) begin : g
    assign d = '1;
  end
  assign o = d[0];
endmodule
module top(output logic o1, o2);
  sub #(.CFG('{DAT: 16, ADR: 2})) u1(.o(o1));
  sub u2(.o(o2));
endmodule
