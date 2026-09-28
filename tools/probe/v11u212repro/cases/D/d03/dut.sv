// § sizeDimOvrFileAtDim212 — verifier: a three-file override chain: the grandparent file overrides the parent, the parent passes its parameter on
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic o);
  mid #(.M(4)) u (.o(o));
endmodule
