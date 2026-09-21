// r11u74 b2 — LAW B, THE NAMESAKE HOMES.  One gen-for block, one row per
// home kind; every Rhs is the same constant so the ONLY thing that can vary
// is the Lhs ref's vpiActual.
module dut (input logic p_in, output logic [31:0] o);
  logic  [31:0] v_ns;        // module-body VARIABLE namesake
  wire   [31:0] n_ns;        // module-body NET namesake
  logic  [15:0] w_ns;        // module-body namesake of a DIFFERENT width
  parameter int P_NS = 5;    // module PARAMETER namesake
  logic  [31:0] mod_only;    // declared only at module level

  for (genvar i = 0; i < 2; i = i + 1) begin : ga
    logic [31:0] v_ns;       // var namesake of a module VAR
    logic [31:0] n_ns;       // var namesake of a module NET
    logic [31:0] w_ns;       // var namesake of a NARROWER module var
    logic [31:0] P_NS;       // var namesake of a module PARAMETER
    logic [31:0] p_in;       // var namesake of a module PORT net
    logic [31:0] own;        // no namesake anywhere
    wire  [31:0] netown;     // gen-local NET, no namesake
    wire  [31:0] netns;      // gen-local NET namesake of a module VAR
    logic [31:0] anc;        // the ancestor-hop source
    assign v_ns   = 32'd7;
    assign n_ns   = 32'd7;
    assign w_ns   = 32'd7;
    assign P_NS   = 32'd7;
    assign p_in   = 32'd7;
    assign own    = 32'd7;
    assign netown = 32'd7;
    assign netns  = 32'd7;
    assign mod_only = 32'd7;     // MODULE-level target from inside the block
    if (i == 1) begin : gin
      logic [31:0] deep;         // no namesake
      assign deep = 32'd7;
      assign anc  = 32'd7;       // ANCESTOR gen scope's local
      assign v_ns = 32'd9;       // ancestor gen-local AND module-body namesake
    end
  end
  assign o = ga[0].v_ns ^ ga[0].n_ns ^ ga[0].w_ns ^ ga[0].P_NS ^ ga[0].p_in
           ^ ga[0].own ^ ga[0].netown ^ ga[0].netns ^ ga[0].anc
           ^ ga[1].gin.deep ^ v_ns ^ w_ns ^ mod_only;
  assign v_ns = {31'd0, p_in};
endmodule
