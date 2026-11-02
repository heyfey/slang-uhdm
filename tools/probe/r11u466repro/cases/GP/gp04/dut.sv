// § genIfcViewSharesParamAssigns466
interface types_if #(parameter int PW = 5);
  localparam int PB = PW*2;
  logic [PW-1:0] t;
endinterface

interface flit_if (types_if ty);
  logic [3:0] f;
  modport mp (input f);
endinterface

module gen_port (interface gi, output logic o); assign o = gi.t[0]; endmodule
module m_use (flit_if.mp fi, output logic o); assign o = fi.f[0]; endmodule

module top (output logic [3:0] o);
  types_if #(.PW(9)) ty ();
  flit_if fl (.ty(ty));
  m_use    u0 (.fi(fl.mp), .o(o[0]));
  gen_port u1 (.gi(ty), .o(o[1]));
endmodule
