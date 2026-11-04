package p;
  localparam [2*4-1:0] B = 8'h3;
  localparam [1+2+3:0] D = 7'h3;
endpackage
module u05(output logic [31:0] o);
  assign o = p::B + p::D;
endmodule
