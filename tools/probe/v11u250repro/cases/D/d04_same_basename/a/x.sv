// § kwAliasDeclResolves250v
module ma(output logic [7:0] o);
  p::al_t v;
  initial v = 1.0;
  assign o = 8'(int'(v));
endmodule
