// § sizeDimOvrFileAtDim212 — the child: an interface-array port sized by a parameter the parent overrides (Rggen's register_if[REGISTERS])
module c #(parameter int N = 1) (bi.m p [N], output logic o);
  assign o = p[0].w;
endmodule
