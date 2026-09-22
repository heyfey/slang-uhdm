// v11u88 v22 -- the net DECLARATION's delay written as a PARAMETER reference,
// and a literal-delay one beside it (the cell carries the declaration delay).
interface ifc ();
  localparam int D = 3;
  wire [31:0] #D w_dp = 32'd11;
  wire [31:0] #2 w_dl = 32'd12;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_dp ^ u_if.w_dl;
endmodule
