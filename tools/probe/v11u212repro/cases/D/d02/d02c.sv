// § sizeDimOvrFileAtDim212 — verifier: the child file
`define SZ N
module c #(parameter int N = 1) (bi.m p [`SZ], output logic o);
  assign o = p[0].w;
endmodule
