// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o);
  logic [3:0] x;
  localparam int T = ($bits(x) == 4) ? 3'sb101 : 3'sb011;
  assign o = T;
endmodule
