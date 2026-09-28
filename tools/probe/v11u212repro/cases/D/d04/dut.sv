// § sizeDimOvrFileAtDim212 — verifier: the override by defparam in another file
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic o);
  bi b [5] ();
  c u (.p(b), .o(o));
  defparam u.N = 5;
endmodule
