package p;
  localparam [32-1:0] A = 32'h10;
endpackage
module u04(output logic [31:0] o);
  assign o = p::A;
endmodule
