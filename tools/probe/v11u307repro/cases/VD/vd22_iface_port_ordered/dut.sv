// § deepStubIfacePortActual307v
interface ifc; logic w; endinterface
module a_m (ifc p, output logic o);
  module b_m (ifc p, output logic o);
    module c_m (ifc q, output logic r); assign r = q.w; endmodule
    c_m u_c (p, o);
  endmodule
  b_m u_b (.p(p), .o(o));
endmodule
module dut (output logic o);
  ifc u_if ();
  a_m u_a (.p(u_if), .o(o));
endmodule
