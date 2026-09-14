module top(input logic [31:0] a, output logic [127:0] o);
  if (1) begin : gb
    assign o = (1) ? {2{64'hFFFF_FFFF_FFFF_FFFF}} : '0;
  end
endmodule
