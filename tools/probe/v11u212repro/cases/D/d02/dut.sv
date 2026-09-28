// § sizeDimOvrFileAtDim212 — verifier: the size dimension written through a macro in the child file
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic o);
  bi b [3] ();
  c #(.N(3)) u (.p(b), .o(o));
endmodule
