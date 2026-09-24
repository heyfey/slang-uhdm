// § implicitNetMintNoFile131
// case f02: disable of a named fork block
module top(input logic clk, output logic y);
  initial begin
    fork : fk
      #5 y = 1'b1;
      #10 y = 1'b0;
    join_any
    disable fk;
  end
endmodule
