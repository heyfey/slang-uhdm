// § caInsideRhsClonesCell301
module child (input logic [3:0] a, output logic o);
  assign o = a inside {[2:5]};
endmodule
module dut #(parameter bit G = 1) (input logic [3:0] a, output logic o);
  if (G) begin : g
    child u (.a(a), .o(o));
  end
endmodule
