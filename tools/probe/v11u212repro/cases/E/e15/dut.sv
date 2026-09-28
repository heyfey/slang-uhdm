// § ndaSysCallNetTs212 — verifier: a net in a generate block initialized by $signed
module dut (input logic [3:0] i, output logic [3:0] o);
  if (1) begin : gb
    wire signed [3:0] w = $signed(i);
    assign o = w;
  end
endmodule
