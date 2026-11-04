// f06 header (§ sizeDimOvrFileAtDim212)
module c #(parameter int N = 1) (bi.m p [N], output logic o);
  assign o = p[0].w;
endmodule
