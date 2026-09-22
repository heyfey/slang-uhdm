// v11u88 v9 -- an interface holding another interface, each with a
// net-decl-assign, plus a both-drive assign in the inner one.
interface inner ();
  wire [31:0] w_in = 32'd21;
  logic [31:0] c_in;
  assign (weak1, strong0) #1 c_in = 32'd22;
endinterface

interface outer ();
  wire [31:0] w_out = 32'd31;
  inner u_in ();
endinterface

module dut (output logic [31:0] o);
  outer u_o ();
  assign o = u_o.w_out ^ u_o.u_in.w_in;
endmodule
