// § defGenLpRangedTs430
interface ifc ();
  for (genvar k = 0; k < 2; k++) begin : g
    localparam [7:0] a = k;
    logic [7:0] v = a;
  end
endinterface
module top (); ifc u(); endmodule
