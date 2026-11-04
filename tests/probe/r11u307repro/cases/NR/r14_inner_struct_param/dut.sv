// § nestedDefSecondBodyReadsRep307
package pk; typedef struct packed { logic [3:0] a; } s_t; endpackage
module outer (output logic [3:0] y);
  module inner #(parameter pk::s_t S = '{a: 4'd3}) (output logic [3:0] o);
    assign o = S.a;
  endmodule
  inner u_i (.o(y));
endmodule
module dut (output logic [7:0] y);
  outer u_o (.y(y[3:0]));
  outer u_p (.y(y[7:4]));
endmodule
