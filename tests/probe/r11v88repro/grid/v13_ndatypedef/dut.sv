// v11u88 v13 -- a TYPEDEF'd vector net with an initializer (a NAMED typespec:
// the unparent rule reads `ts->VpiName().empty()`).
package pk;
  typedef logic [15:0] v_t;
  localparam v_t PV = 16'h1234;
endpackage

interface ifc ();
  pk::v_t w_td = pk::PV;
  wire [31:0] w_pl = 32'd11;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = {16'd0, u_if.w_td} ^ u_if.w_pl;
endmodule
