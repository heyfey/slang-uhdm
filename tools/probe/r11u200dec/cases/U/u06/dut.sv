localparam W = 4;
localparam [(2*4)-1:0] B = 8'h3;
localparam [1+2+3:0] D = 7'h3;
localparam [W*2-1:0] E = 8'h3;
localparam [W-1:W-4] F = 4'h3;
module u06(output logic [31:0] o);
  assign o = B + D + E + F;
endmodule
