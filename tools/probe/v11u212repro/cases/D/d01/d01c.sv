// § sizeDimOvrFileAtDim212 — verifier: the child file
module c #(parameter int N = 1) (output logic o);
  bi b [N] ();
  assign o = b[0].w;
endmodule
