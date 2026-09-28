// § sizeDimOvrFileAtDim212 — verifier: an interface-array INSTANCE in the child sized by an overridden parameter, the override in another file
interface bi;
  logic w;
endinterface
module dut(output logic o);
  c #(.N(3)) u (.o(o));
endmodule
