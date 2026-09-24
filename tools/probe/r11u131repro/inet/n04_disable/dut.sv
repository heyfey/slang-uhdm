// § implicitNetMintNoFile131
module top(input logic clk, output logic o);
  initial begin : loop
    o = 1'b0;
    disable loop;
  end
endmodule
