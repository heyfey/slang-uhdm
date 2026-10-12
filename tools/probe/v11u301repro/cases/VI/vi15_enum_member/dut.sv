// § caInsideRhsClonesCell301
module dut (input logic [1:0] a, output logic o);
  typedef enum logic [1:0] {IDLE, RUN, STOP} st_e;
  st_e s;
  assign s = st_e'(a);
  assign o = s inside {IDLE, STOP};
endmodule
