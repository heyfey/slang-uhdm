// v98 V4c -- AN INTERFACE LEVEL IN THE CHAIN.  A module instantiated inside
// a GENERATE of an interface is illegal; instead the interface is a PORT of
// the leaf's parent, and the leaf sits under a module whose ancestor chain
// crosses an interface INSTANCE.  bindVariable has no uhdminterface_inst case
// -> the interface's own names must NOT count, a module name above it must.
interface v4cif98 (input logic clk);
  logic i_only;                   // interface-only: must NOT count
  logic m_above;                  // ALSO a module name above -> must count
  assign i_only = 1'b0;
  assign m_above = 1'b0;
endinterface
module v4cleaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin : gen_b
    logic [1:0] p1, p2;
    logic i_only;                 // name lives only in the interface
    logic m_above;                // name lives in a MODULE above too
    logic n_free;
    assign i_only  = (p1 == p2);
    assign m_above = (p1 != p2);
    assign n_free  = (p1 <  p2);
    assign o = i_only ^ m_above ^ n_free;
    always_ff @(posedge clk) begin p1 <= a; p2 <= p1; end
  end
endmodule
module v4cmid98 (v4cif98 ifp, input logic [1:0] a, output logic o);
  v4cleaf98 u_leaf (.clk(ifp.clk), .a(a), .o(o));
endmodule
module v4c_ifc98 (input logic clk, input logic [1:0] a, output logic o);
  logic m_above;                  // the MODULE-level name
  assign m_above = 1'b0;
  v4cif98 u_if (.clk(clk));
  v4cmid98 u_mid (.ifp(u_if), .a(a), .o(o));
endmodule
