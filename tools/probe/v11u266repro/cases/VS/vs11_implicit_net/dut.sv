// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o);
  localparam int P = 8'sh3C;
  assign imp = P[0];
  assign o = {31'b0, imp};
endmodule
