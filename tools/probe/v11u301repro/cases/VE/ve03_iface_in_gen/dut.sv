// § ifCaConstDelayPerCell301
interface ifc ();
  logic [7:0] p;
  assign #2 p = 8'd1;
endinterface
module dut #(parameter bit G = 1) (output logic [7:0] o);
  if (G) begin : g
    ifc u0 ();
  end
  ifc u1 ();
  assign o = g.u0.p ^ u1.p;
endmodule
