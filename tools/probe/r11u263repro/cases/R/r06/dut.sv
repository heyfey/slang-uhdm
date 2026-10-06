// § genLpArrRangeFirst263
module sub #(parameter bit [1:0] P = 0) (output logic [1:0] o);
  assign o = P;
endmodule
module top(output logic [1:0] o);
  case (1)
    1: begin : c
      localparam bit [1:0] Q[2][2] = '{'{2'h0, 2'h1}, '{2'h2, 2'h3}};
      sub #(.P(Q[1][0])) u (.o(o));
    end
  endcase
endmodule
