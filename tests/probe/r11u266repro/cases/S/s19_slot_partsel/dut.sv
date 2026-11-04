// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 4'sh2;
  assign o = x[P+1:P];
endmodule
