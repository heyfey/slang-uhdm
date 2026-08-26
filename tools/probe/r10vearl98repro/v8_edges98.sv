// v98 V8 -- REMAINING FACES: an ANONYMOUS gen block, an ancestor reached
// through a MODULE ARRAY, an ancestor that itself lives in a GENERATE block,
// and a gen scope owned by an INTERFACE (earl98 R2).
module v8leaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin                       // ANONYMOUS -> genblk1
    logic [1:0] g1, g2;
    logic e_anon;                    // shadowed at d1
    logic e_arr;                     // shadowed in the ARRAY parent
    logic e_gena;                    // shadowed in a module inside a GENERATE
    logic e_none;
    assign e_anon = (g1 == g2);
    assign e_arr  = (g1 != g2);
    assign e_gena = (g1 <  g2);
    assign e_none = (g1 >  g2);
    assign o = e_anon ^ e_arr ^ e_gena ^ e_none;
    always_ff @(posedge clk) begin g1 <= a; g2 <= g1; end
  end
endmodule
module v8arr98 (input logic clk, input logic [1:0] a, output logic o);
  logic e_anon, e_arr;
  assign e_anon = 1'b0;
  assign e_arr  = 1'b0;
  v8leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
interface v8if98 (input logic clk);
  logic [1:0] h1, h2;
  if (1) begin : gen_i
    logic [1:0] k1, k2;
    logic e_ifgen;                   // shadowed in the MODULE above (R2 probe)
    assign e_ifgen = (k1 == k2);
    always_ff @(posedge clk) begin k1 <= k1 + 1'b1; k2 <= k1; end
  end
endinterface
module v8_edges98 (input logic clk, input logic [1:0] a, output logic [1:0] o);
  logic e_gena;
  logic e_ifgen;                     // the interface gen scope's shadow
  assign e_gena  = 1'b0;
  assign e_ifgen = 1'b0;
  v8arr98 u_arr [1:0] (.clk(clk), .a(a), .o(o));
  if (1) begin : gen_host
    v8leaf98 u_g (.clk(clk), .a(a), .o());
  end
  v8if98 u_if (.clk(clk));
endmodule
