// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p;
  assign #5 p = 8'd1;
  modport mp (input p);
endinterface
module child (ifc.mp i, output logic [7:0] o);
  assign o = i.p;
endmodule
module dut (output logic [15:0] o);
  ifc u0 ();
  ifc u1 ();
  child c0 (.i(u0), .o(o[7:0]));
  child c1 (.i(u1), .o(o[15:8]));
endmodule
