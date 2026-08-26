// r10earl98 g2 -- THE ANCESTOR DECLARATION-KIND AXIS.  Surelog's
// `bindVariable` module_inst case searches ONLY `Variables()` then `Nets()`.
// A parameter, a typedef, a function, a child INSTANCE name or a genvar of the
// ancestor must NOT count; a wire, a logic var and a PORT must.
module k1leaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin : gen_b
    logic [1:0] r1, r2;
    logic k_wire;    // ancestor: wire
    logic k_var;     // ancestor: logic variable
    logic k_port;    // ancestor: module PORT
    logic k_param;   // ancestor: localparam  (must NOT count)
    logic k_func;    // ancestor: function    (must NOT count)
    logic k_inst;    // ancestor: instance name (must NOT count)
    logic k_arr;     // ancestor: unpacked array variable
    assign k_wire  = (r1 == r2);
    assign k_var   = (r1 != r2);
    assign k_port  = (r1 <  r2);
    assign k_param = (r1 >  r2);
    assign k_func  = (r1 <= r2);
    assign k_inst  = (r1 >= r2);
    assign k_arr   = (r1 == r2) & (r1 != r2);
    assign o = k_wire ^ k_var ^ k_port ^ k_param ^ k_func ^ k_inst ^ k_arr;
    always_ff @(posedge clk) begin
      r1 <= a;
      r2 <= r1;
    end
  end
endmodule

module k1sub98 (input logic clk, output logic q);
  assign q = clk;
endmodule

module g2_kind98 (input logic clk, input logic [1:0] a, output logic o,
                  output logic k_port);
  wire  k_wire;
  logic k_var;
  logic k_arr [0:1];
  localparam int k_param = 3;
  function automatic logic k_func(input logic z); return ~z; endfunction
  assign k_wire = 1'b0;
  assign k_var  = 1'b0;
  assign k_port = 1'b0;
  k1sub98 k_inst (.clk(clk), .q());
  k1leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
