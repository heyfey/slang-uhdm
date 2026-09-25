// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [3:0] o);
  always_comb begin : blk
    localparam int H = 7;
    localparam int L = 4;
    o = a[H:L];
  end
endmodule
