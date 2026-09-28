localparam [32-1:0] A = 32'h10;
localparam [2*4-1:0] B = 8'h3;
module u01(output logic [31:0] o);
  assign o = A + B;
endmodule
