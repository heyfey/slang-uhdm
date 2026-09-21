// v11u71 x4 — A FOR-GENERATE ARRAY.  Each iteration is its own gen_scope with
// its own local; the namesake walk must answer per instance, and the ancestor
// hop must cross a gen_scope_array.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  localparam cfg_t LIT = '{n: 300, m: 8'hA5};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  logic [7:0] ns;                      // module-body namesake, 8 bits
  logic [63:0] acc;
  genvar gi;
  for (gi = 0; gi < 3; gi = gi + 1) begin : gl
    logic [31:0] ns;                   // namesake hit, per iteration
    logic [31:0] lv;                   // no namesake
    assign ns = CFG.n;
    assign lv = CFG.m;
    if (gi == 1) begin : gin
      logic [15:0] deep;
      assign deep = CFG.n;             // nested inside the loop body
      assign lv   = CFG.n;             // ANCESTOR gen-local target
    end
  end
  assign o = {32'd0, gl[0].ns} ^ {32'd0, gl[1].lv} ^ {48'd0, gl[1].gin.deep}
           ^ {32'd0, gl[2].ns};
  assign ns = 8'd0;
endmodule
