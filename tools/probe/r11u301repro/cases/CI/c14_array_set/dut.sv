// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  logic [3:0] arr [2];
  assign arr[0] = 4'd1;
  assign arr[1] = 4'd2;
  assign o = a inside {arr};
endmodule
