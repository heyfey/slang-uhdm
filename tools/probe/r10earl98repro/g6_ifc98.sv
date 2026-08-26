// r10earl98 g6 -- THE NEGATIVE / AWAY-RISK ARM.
//  (a) an INTERFACE-level name is NEVER found by Surelog's write-time
//      `bindVariable`: it switches on uhdmfunction / uhdmtask / uhdmbegin /
//      uhdmmodule_inst and NOTHING else, so an interface_inst level is
//      recursed PAST (the r10earl59 fence).  `i_only` is declared ONLY in the
//      interface that owns the gen scope; `m_only` only in the module above it.
//  (b) the ancestor DECLARATION-KIND axis re-run at d0 (the enclosing scope's
//      OWN body), where the shipped clause tests EVERY member kind.
//  (c) a gen-local whose name matches an ancestor GENVAR or TYPEDEF.
interface i1if98 (input logic clk, input logic [1:0] a);
  logic i_only;              // interface level: must NOT count
  localparam int z_param = 1;
  wire  z_net;
  typedef logic z_td;
  assign i_only = 1'b0;
  assign z_net  = 1'b0;
  if (1) begin : gen_b
    logic [1:0] y1, y2;
    logic i_only;
    logic m_only;            // module level, two scopes up: MUST count
    logic z_param;
    logic z_net;
    logic z_gv;
    logic z_td;
    assign i_only  = (y1 == y2);
    assign m_only  = (y1 != y2);
    assign z_param = (y1 <  y2);
    assign z_net   = (y1 <= y2);
    assign z_gv    = (y1 >= y2);
    assign z_td    = (y1 == y2) & (y1 != y2);
  end
endinterface

module m1leaf98 (input logic clk, input logic [1:0] a, output logic o);
  localparam int w_param = 1;
  function automatic logic w_func(input logic z); return ~z; endfunction
  wire  w_net;
  logic w_var;
  assign w_net = 1'b0;
  assign w_var = 1'b0;
  if (1) begin : gen_b
    logic [1:0] x1, x2;
    logic w_param;   // d0 localparam
    logic w_func;    // d0 function
    logic w_net;     // d0 wire
    logic w_var;     // d0 logic var
    logic w_none;    // nothing
    assign w_param = (x1 == x2);
    assign w_func  = (x1 != x2);
    assign w_net   = (x1 <  x2);
    assign w_var   = (x1 >  x2);
    assign w_none  = (x1 <= x2);
    assign o = w_param ^ w_func ^ w_net ^ w_var ^ w_none;
    always_ff @(posedge clk) begin
      x1 <= a;
      x2 <= x1;
    end
  end
endmodule

module g6_ifc98 (input logic clk, input logic [1:0] a, output logic o);
  logic m_only;
  logic z_gv;
  assign m_only = 1'b0;
  assign z_gv   = 1'b0;
  i1if98 u_if (.clk(clk), .a(a));
  m1leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
