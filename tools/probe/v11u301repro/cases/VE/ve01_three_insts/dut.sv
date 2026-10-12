// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p, q;
  assign #3 p = 8'd1, q = 8'd2;
endinterface
module dut (output logic [7:0] o);
  ifc u0 ();
  ifc u1 ();
  ifc u2 ();
  assign o = u0.p ^ u1.q ^ u2.p;
endmodule
