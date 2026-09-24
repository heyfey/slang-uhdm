// § implicitNetMintNoFile131
module top (input logic clk, output logic o);
  always @(posedge clk) begin : outer
    begin : inner
      o <= 1'b0;
      disable outer;
    end
  end
endmodule
