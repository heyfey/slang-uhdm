// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p, q;
  assign #1 p = 8'd1;
  assign #2 q = 8'd2;
endinterface
module dut (output logic [7:0] o);
  ifc u0 ();
  ifc u1 ();
  assign o = u0.p ^ u1.q;
endmodule
