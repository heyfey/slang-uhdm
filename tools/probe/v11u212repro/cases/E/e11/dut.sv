// § ndaSysCallNetTs212 — verifier: a scalar net initialized by $signed
module dut (input logic [5:0] i, output logic o);
  wire w = $signed(i[0]);
  assign o = w;
endmodule
