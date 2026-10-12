// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p;
  assign #(6) p = 8'd1;
endinterface
module dut (output logic [7:0] o);
  ifc u0 ();
  ifc u1 ();
  assign o = u0.p ^ u1.p;
endmodule
