// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p;
  assign #2 p = 8'd1;
endinterface
module dut (output logic [7:0] o);
  ifc u [1:0] ();
  assign o = u[0].p ^ u[1].p;
endmodule
