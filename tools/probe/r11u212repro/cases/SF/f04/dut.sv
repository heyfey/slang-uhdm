// § sizeDimOvrFileAtDim212 — the parent in another file leaves the size parameter at its default (control)
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic o);
  bi b [1] ();
  c u (.p(b), .o(o));
endmodule
