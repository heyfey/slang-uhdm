// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = logic [3:0]);
  T d;
  modport mp (input d);
endinterface
module sink (ifc.mp p, output logic o);
  assign o = ^p.d;
endmodule
module dut (output logic o);
  ifc #(.T(logic [5:0])) u ();
  sink s (.p(u), .o(o));
endmodule
