// § implicitNetMintNoFile131
module top(input logic [3:0] i, output logic [3:0] o);
  always_comb begin : blk
    localparam int K = 2;
    o = i + K;
  end
endmodule
