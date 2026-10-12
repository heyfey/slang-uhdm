// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p;
  assign #7 p = 8'd3;
endinterface
module dut (output logic [7:0] o);
  ifc u0 ();
  assign o = u0.p;
endmodule
