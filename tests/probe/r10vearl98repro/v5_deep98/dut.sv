// v98 V5 -- a PROGRAM level in the chain, a d4/d5 shadow, and an ancestor
// whose matching name is a PARAMETER / TYPEDEF / GENVAR / INSTANCE (which
// bindVariable never reads) at the same depth as a real net.
module v5leaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin : gen_b
    logic [1:0] w1, w2;
    logic z_d4;      // a NET four module instances up
    logic z_par;     // a PARAMETER one instance up  -> golden must KEEP
    logic z_typ;     // a TYPEDEF   one instance up  -> golden must KEEP
    logic z_gv;      // a GENVAR    one instance up  -> golden must KEEP
    logic z_inst;    // an INSTANCE name one up      -> golden must KEEP
    assign z_d4  = (w1 == w2);
    assign z_par = (w1 != w2);
    assign z_typ = (w1 <  w2);
    assign z_gv  = (w1 >  w2);
    assign z_inst= (w1 <= w2);
    assign o = z_d4 ^ z_par ^ z_typ ^ z_gv ^ z_inst;
    always_ff @(posedge clk) begin w1 <= a; w2 <= w1; end
  end
endmodule
module v5l1_98 (input logic clk, input logic [1:0] a, output logic o);
  localparam int z_par = 3;
  typedef logic z_typ;
  genvar z_gv;
  v5leaf98 z_inst (.clk(clk), .a(a), .o(o));
endmodule
module v5l2_98 (input logic clk, input logic [1:0] a, output logic o);
  v5l1_98 u1 (.clk(clk), .a(a), .o(o));
endmodule
module v5l3_98 (input logic clk, input logic [1:0] a, output logic o);
  v5l2_98 u2 (.clk(clk), .a(a), .o(o));
endmodule
module v5_deep98 (input logic clk, input logic [1:0] a, output logic o);
  logic z_d4;
  assign z_d4 = 1'b0;
  v5l3_98 u3 (.clk(clk), .a(a), .o(o));
endmodule
