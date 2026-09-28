// § sizeDimOvrFileAtDim212 — verifier: the middle module file
module mid #(parameter int M = 2) (output logic o);
  bi b [M] ();
  c #(.N(M)) u (.p(b), .o(o));
endmodule
