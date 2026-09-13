// d10 — the NON-cont_assign reading contexts, the control for "is the fold
// keyed on the continuous assignment at all": a procedural read, a port
// connection, a range bound, a case item and a function-call argument.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.base = 64'h1000;
    return r;
  endfunction
endpackage

module sink (input logic [31:0] i, output logic [31:0] o);
  assign o = i;
endmodule

module dut #(parameter p::cfg_t CFG = p::build()) (
    input  logic        clk,
    output logic [31:0] o_proc,
    output logic [31:0] o_port,
    output logic [31:0] o_reg
);
  logic [CFG.n-1:0] rngv;              // a RANGE bound
  always_comb o_proc = CFG.n;          // PROCEDURAL read
  always_ff @(posedge clk) o_reg <= CFG.n;
  sink u_s (.i(CFG.n), .o(o_port));    // PORT connection
  assign rngv = '0;
endmodule
