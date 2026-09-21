// r11u71 n2 — WHICH SCOPE DOES `bindVariable` SEARCH?  One member (32 bits,
// value 300) written onto targets whose NAME lives in a different home each
// time.  The answer is the substituted constant's SIZE: the member's own 32
// when the walk finds nothing, the FOUND declaration's width when it does.
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

module leaf #(parameter p::cfg_t C = p::LIT) (output logic [63:0] o);
  // an ANCESTOR-INSTANCE namesake is `anc` in dut's body (4 bits)
  if (1) begin : gi
    logic [31:0] anc;
    assign anc = C.n;
  end
  assign o = {32'd0, gi.anc};
endmodule

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o1, output logic [15:0] po);
  logic [7:0]   mb;       // module-body namesake, 8 bits
  logic [3:0]   anc;      // the ancestor-instance namesake, 4 bits
  localparam    lpn = 9;  // a namesake that is a PARAMETER, not a var/net
  wire          imp;      // an explicit 1-bit net namesake
  logic [63:0] sink;
  leaf u_l (.o(sink));
  if (1) begin : gown
    logic [31:0] lv;      // no namesake anywhere
    assign lv = CFG.n;
  end
  if (1) begin : gmb
    logic [31:0] mb;      // module-body namesake, 8 bits
    assign mb = CFG.n;
  end
  if (1) begin : gpo
    logic [31:0] po;      // a module PORT namesake, 16 bits
    assign po = CFG.n;
  end
  if (1) begin : glp
    logic [31:0] lpn;     // a PARAMETER namesake: not a Variable/Net
    assign lpn = CFG.n;
  end
  if (1) begin : gimp
    logic [31:0] imp;     // a 1-bit net namesake
    assign imp = CFG.n;
  end
  if (1) begin : ganc0
    logic [31:0] av;      // ancestor GEN-scope local, 32 bits
    if (1) begin : gin
      assign av = CFG.n;  // target is the ANCESTOR gen scope's local
    end
  end
  if (1) begin : gnet
    wire [31:0] wv;       // a gen-local NET target
    assign wv = CFG.n;
  end
  assign o1 = {32'd0, gown.lv} ^ {32'd0, gmb.mb} ^ {32'd0, glp.lpn}
              ^ {32'd0, ganc0.av} ^ {32'd0, gnet.wv} ^ {63'd0, gimp.imp} ^ sink;
  assign mb = 8'd0;
  assign anc = 4'd0;
endmodule
