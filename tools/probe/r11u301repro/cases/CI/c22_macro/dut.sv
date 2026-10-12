// § caInsideRhsClonesCell301
`define IN(x) x inside {4'd1, 4'd2}
module dut (input logic [3:0] a, output logic o);
  assign o = `IN(a);
endmodule
