interface tif #(parameter int PW = 5);
  localparam int PB = PW*2;
  logic [PW-1:0] t;
  modport mp (input t);
endinterface

interface fif (tif ty);
  logic [3:0] f;
  modport mp (input f);
endinterface

module gen_port (interface gi, output logic o); assign o = gi.t[0]; endmodule
module arr_port (tif.mp m [2],  output logic o); assign o = m[0].t[0]; endmodule
module use_fl   (fif.mp fi, output logic o); assign o = fi.f[0]; endmodule

module top (output logic [3:0] o);
  tif #(.PW(9)) ty ();
  tif #(.PW(9)) arr [2] ();
  fif fl (.ty(ty));
  use_fl   u0 (.fi(fl.mp), .o(o[0]));
  gen_port u1 (.gi(ty),    .o(o[1]));
  arr_port u2 (.m(arr),    .o(o[2]));
  assign o[3] = 1'b0;
endmodule
