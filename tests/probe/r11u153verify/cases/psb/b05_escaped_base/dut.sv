// § psBoundBareRefByBase145
module dut(input logic [31:0] \a$b , output logic [3:0] o);
  localparam int H = 7;
  localparam int L = 4;
  assign o = \a$b [H:L];
endmodule
