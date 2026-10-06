// § genLpArrRangeFirst263
package p; typedef struct packed { logic a; logic b; } s_t; endpackage
module sub #(parameter p::s_t P = 0) (output logic o);
  assign o = P.a;
endmodule
module top(output logic o);
  if (1) begin : g
    localparam p::s_t S[2] = '{'{1'b0, 1'b1}, '{1'b1, 1'b0}};
    sub #(.P(S[1])) u (.o(o));
  end
endmodule
