// § defGenLpNoBlockListed430
interface ifc #(parameter N = 0) ();
  for (genvar k = 0; k < N; k++) begin : g
    localparam a = 3;
  end
endinterface
module top (); ifc u(); endmodule
