// § deepStubIfacePortActual307v
interface ifc; logic w; modport mp (input w); endinterface
module a_m (ifc.mp p, output logic o);
  module b_m (ifc.mp p, output logic o);
    module c_m (ifc.mp q, output logic r); assign r = q.w; endmodule
    c_m u_c (.q(p), .r(o));
  endmodule
  b_m u_b (.p(p), .o(o));
endmodule
module dut (output logic o);
  ifc u_if ();
  a_m u_a (.p(u_if), .o(o));
endmodule
