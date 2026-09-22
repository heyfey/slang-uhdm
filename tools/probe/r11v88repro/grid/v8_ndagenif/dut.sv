// v11u88 v8 -- net-decl-assign inside a GENERATE IF in an interface body,
// beside a body-level one.
interface ifc #(parameter int P = 1) ();
  wire [31:0] w_body = 32'd11;
  if (P == 1) begin : gblk
    wire [31:0] w_gen = 32'd12;
  end
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_body ^ u_if.gblk.w_gen;
endmodule
