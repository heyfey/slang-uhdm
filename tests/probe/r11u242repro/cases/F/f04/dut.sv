// § s2CloneGenScopeInst242
// (with § patLeftoverOpCopy242) The module holder at depth 2 and inside a generate block, the stamped member read in
// constant slots of the holder module (a part-select width, a replication count, a dimension
// bound written beside it; the members read there fold, a face of their own).
package cp;
  typedef struct packed {
    int unsigned n;
    logic [3:0][63:0] base;
  } ucfg_t;
  typedef struct packed {
    int unsigned n;
    logic [3:0][63:0] base;
    bit z;
  } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(2), base: 256'({64'h4, 64'h8})};
  function automatic cfg_t build(ucfg_t c);
    cfg_t r;
    r.n = c.n;
    r.base = c.base;
    r.z = c.n && c.base;
    return r;
  endfunction
endpackage
module leaf #(parameter cp::cfg_t C = cp::build(cp::U)) (input logic [7:0] i, output logic [7:0] o, output logic [1:0] q);
  assign o = {2{i[0 +: 4]}};
  assign q = i[1:0];
endmodule
module mid (input logic [7:0] i, output logic [7:0] o, output logic [1:0] q);
  if (1) begin : g
    leaf u (.i(i), .o(o), .q(q));
  end
endmodule
module top (input logic [7:0] i, output logic [7:0] o, output logic [1:0] q);
  mid m (.i(i), .o(o), .q(q));
endmodule
