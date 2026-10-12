// § ifCaConstDelayPerCell301
interface ifc ();
  logic [31:0] p;
  assign #4 p = 32'd1;
endinterface
module dut (output logic [31:0] o);
  ifc u0 ();
  ifc u1 ();
  assign o = u0.p ^ u1.p;
endmodule
