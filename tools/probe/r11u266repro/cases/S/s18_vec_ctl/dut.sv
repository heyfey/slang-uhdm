// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam logic signed [11:0] P = 12'shFFF;
  assign o = P;
endmodule
