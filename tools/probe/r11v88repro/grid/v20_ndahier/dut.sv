// v11u88 v20 -- a net-decl-assign whose NAME is a parameter of the INTERFACE's
// own parameter port list, on two differently-parametrised instances.
interface ifc #(parameter int P = 5) ();
  wire [31:0] w_p = P;
endinterface

module dut (output logic [31:0] o);
  ifc #(.P(7)) u1 ();
  ifc #(.P(9)) u2 ();
  assign o = u1.w_p ^ u2.w_p;
endmodule
