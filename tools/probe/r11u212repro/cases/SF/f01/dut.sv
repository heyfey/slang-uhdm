// § sizeDimOvrFileAtDim212 — the parent in another file overrides the size parameter by name with a literal
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic o);
  bi b [3] ();
  c #(.N(3)) u (.p(b), .o(o));
endmodule
