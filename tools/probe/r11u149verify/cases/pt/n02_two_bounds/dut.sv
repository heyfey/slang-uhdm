// § paramAliasBoundRefUnstored144
module dut #(parameter int X = 6, parameter int Z = 2) (output logic [7:0] o);
  typedef logic [X-1:Z] my_t;
  parameter my_t Y = 5;
  assign o = Y;
endmodule
