// § sizeDimOvrFileAtDim212 — verifier: the child file
module c #(parameter int N = 1) (bi.m p [N], output logic o);
  assign o = p[N-1].w;
endmodule
