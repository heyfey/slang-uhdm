`define XL 32
localparam [`XL-1:0] A = 32'h10;
module u02(output logic [31:0] o);
  assign o = A;
endmodule
