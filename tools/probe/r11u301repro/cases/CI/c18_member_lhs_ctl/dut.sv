// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic [1:0] o);
  struct packed { logic x; logic y; } s;
  assign s.x = a inside {[4'd2:4'd6]};
  assign s.y = 1'b0;
  assign o = s;
endmodule
