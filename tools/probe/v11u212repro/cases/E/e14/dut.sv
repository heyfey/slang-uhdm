// § ndaSysCallNetTs212 — verifier: a net initialized by $signed in a child instantiated in a generate loop
module c (input logic [3:0] i, output logic [3:0] o);
  wire signed [3:0] w = $signed(i);
  assign o = w;
endmodule
module dut (input logic [7:0] i, output logic [7:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    c u (.i(i[g*4 +: 4]), .o(o[g*4 +: 4]));
  end
endmodule
