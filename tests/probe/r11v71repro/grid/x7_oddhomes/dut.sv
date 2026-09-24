// v11u71 x7 — NAMESAKES THAT ARE NOT VARIABLES OR NETS.  `bindVariable` scans
// `module_inst->Variables()` then `->Nets()` ONLY, so an instance name, a
// function, a typedef, a genvar and a named block must all MISS; an IMPLICIT
// net is in `Nets()` but carries no typespec `adjustSize` can use.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module sub (output logic [7:0] q);
  assign q = 8'd0;
endmodule

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  typedef logic [9:0] tdname;       // a TYPEDEF namesake
  logic [7:0] qq;
  sub instname (.q(qq));            // an INSTANCE namesake
  function automatic int fname(input int x); return x; endfunction
  genvar gvname;
  wire netdrv;
  assign impl = netdrv;             // IMPLICIT net namesake `impl` (1 bit)
  if (1) begin : g_inst  logic [31:0] instname; assign instname = CFG.n; end
  if (1) begin : g_fn    logic [31:0] fname;    assign fname    = CFG.n; end
  if (1) begin : g_td    logic [31:0] tdname;   assign tdname   = CFG.n; end
  if (1) begin : g_gv    logic [31:0] gvname;   assign gvname   = CFG.n; end
  if (1) begin : g_impl  logic [31:0] impl;     assign impl     = CFG.n; end
  for (gvname = 0; gvname < 1; gvname = gvname + 1) begin : g_loop
    logic [31:0] unused; assign unused = CFG.n;
  end
  assign o = {32'd0, g_inst.instname} ^ {32'd0, g_fn.fname}
           ^ {32'd0, g_td.tdname} ^ {32'd0, g_gv.gvname}
           ^ {32'd0, g_impl.impl} ^ {32'd0, g_loop[0].unused} ^ {56'd0, qq};
endmodule
