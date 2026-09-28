// § sizeDimOvrFileAtDim212 — the parent in another file overrides the size parameter by name with a parameter expression
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut #(parameter int K = 1) (output logic o);
  bi b [3] ();
  c #(.N(K+2)) u (.p(b), .o(o));
endmodule
