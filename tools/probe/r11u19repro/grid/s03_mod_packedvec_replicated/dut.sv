module top(input logic [31:0] a, output logic [3:0] we);
  assign we = '{4{1'b1}};
endmodule
