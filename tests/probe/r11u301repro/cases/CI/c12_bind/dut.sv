// § caInsideRhsClonesCell301
module chk (input logic [3:0] a, output logic f);
  assign f = a inside {[4'd2:4'd6]};
endmodule
module dut (input logic [3:0] a, output logic o);
  logic f;
  assign o = a[0];
endmodule
bind dut chk u_chk (.a(a), .f(f));
