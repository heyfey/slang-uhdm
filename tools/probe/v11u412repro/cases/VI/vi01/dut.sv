// § elabVarSysCallInit412
module top(output logic [31:0] o);
  int r = $urandom;
  time t = $time;
  real rr = $realtime;
  integer q = $random();
  assign o = r;
endmodule
