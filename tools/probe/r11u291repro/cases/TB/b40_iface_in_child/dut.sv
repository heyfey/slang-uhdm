// § tpUseSigBindsTpObj291
interface ifc #(parameter type T = byte);
  T d;
endinterface
module child (output logic o);
  ifc u ();
  assign o = ^u.d;
endmodule
module dut (output logic o);
  child c (.o(o));
endmodule
