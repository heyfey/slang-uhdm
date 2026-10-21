// § decUnszElabRespellKeepsM1_423 (control: the copy a cont_assign reads whole, resized by it)
module top(output logic [7:0] y);
  localparam T = 'd12;
  assign y = T;
endmodule
