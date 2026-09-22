// v11u83 b15 -- LAW A: the imported package name COLLIDES with the
// interface's own PORT name.  The hoisted copy and the port variable share a
// name; the port list, the modport and the elaborated listing all key on it.
package pk;
  logic [7:0] pw;
  wire  [7:0] nw;
endpackage

interface ifc (input logic [15:0] pw, output logic [15:0] nw);
  import pk::*;
  logic [31:0] i_own;
  assign nw = pw;
endinterface

module dut (input logic [15:0] a, output logic [15:0] o);
  ifc u_if (.pw(a), .nw(o));
endmodule
