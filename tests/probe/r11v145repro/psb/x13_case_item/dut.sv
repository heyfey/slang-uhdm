// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic o);
  localparam int W = 8;
  localparam int L = 4;
  always_comb begin
    case (a[W:L])
      5'd1: o = 1'b1;
      default: o = 1'b0;
    endcase
  end
endmodule
