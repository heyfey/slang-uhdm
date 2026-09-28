// § sizeDimOvrFileAtDim212 — r11u217 f02: the child in c.sv, instantiated twice from dut.sv with two override values and once with its default
module c #(parameter int N = 1) (bi.m p [N], output logic o);
  assign o = p[N-1].w;
endmodule
