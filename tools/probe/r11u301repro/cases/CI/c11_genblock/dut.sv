// § caInsideRhsClonesCell301
module dut #(parameter bit E = 1) (input logic [3:0] a, output logic o);
  if (E) begin : g
    assign o = a inside {[4'd1:4'd5]};
  end
endmodule
