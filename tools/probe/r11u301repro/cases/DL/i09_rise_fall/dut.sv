// § ifCaConstDelayPerCell301
interface ifc ();
  wire [31:0] p;
  wire [31:0] q;
  assign #(2, 3) p = 32'd1, q = 32'd2;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.p ^ u_if.q;
endmodule
