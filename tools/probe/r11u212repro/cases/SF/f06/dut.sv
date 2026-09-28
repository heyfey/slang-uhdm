// § sizeDimOvrFileAtDim212 — the child with the sized interface-array port lives in an included header
interface bi;
  logic w;
  modport m (input w);
endinterface
`include "f06c.svh"
module dut(output logic o);
  bi b [3] ();
  c #(.N(3)) u (.p(b), .o(o));
endmodule
