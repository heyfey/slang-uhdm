// § sizeDimOvrFileAtDim212 — r11u217 f02: the same child instantiated with N=2 and N=3 by name and with its default N=1
interface bi;
  logic w;
  modport m (input w);
endinterface
module dut(output logic [2:0] o);
  bi b2 [2] ();
  bi b3 [3] ();
  bi b1 [1] ();
  c #(.N(2)) u2 (.p(b2), .o(o[0]));
  c #(.N(3)) u3 (.p(b3), .o(o[1]));
  c u1 (.p(b1), .o(o[2]));
endmodule
