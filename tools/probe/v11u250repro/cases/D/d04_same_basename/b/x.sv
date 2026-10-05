// § kwAliasDeclResolves250v
module mb(output logic [7:0] o);
  q::al_t v;
  initial v = 2.0;
  assign o = 8'(int'(v));
endmodule
module top(output logic [7:0] o1, o2);
  ma a(.o(o1));
  mb b(.o(o2));
endmodule
