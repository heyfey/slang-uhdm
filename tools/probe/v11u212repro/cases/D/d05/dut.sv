// § sizeDimOvrFileAtDim212 — verifier: the override by a hex literal, the child in another file, instantiated twice with different sizes
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic o, output logic o2);
  bi b [2] ();
  bi e [6] ();
  c #(.N('h2)) u (.p(b), .o(o));
  c #(.N(6)) v (.p(e), .o(o2));
endmodule
