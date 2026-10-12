// § caInsideRhsClonesCell301
typedef logic flag_t;
module dut (input logic [3:0] a, output logic o);
  flag_t f;
  assign f = a inside {[1:3]};
  assign o = f;
endmodule
