// v62j — the module-local typedef in a module instantiated from a GENERATE FOR
// with a per-iteration parameter (each iteration is its own specialization),
// plus a deeper nesting level, plus a def view reached from a LATER instance.
module gf62 #(parameter int W = 1) (input logic clk, output logic [1:0] z);
  typedef enum logic [1:0] { GA, GB, GC } g_e;
  typedef struct packed { g_e op; logic [1:0] sz; } g_t;
  g_t gv;
  assign z = (gv.op == GB) ? gv.sz : 2'b00;
endmodule

module mid62 #(parameter int K = 1) (input logic clk, output logic [1:0] y);
  gf62 #(.W(K + 10)) u_inner (.clk(clk), .z(y));
endmodule

module top62j (input logic clk, output logic [15:0] o);
  logic [1:0] zz [0:3];
  logic [1:0] yy;
  generate
    for (genvar i = 0; i < 4; i++) begin : gl
      gf62 #(.W(i + 1)) u (.clk(clk), .z(zz[i]));
    end
  endgenerate
  mid62 #(.K(7)) u_mid (.clk(clk), .y(yy));
  assign o = {6'b0, yy, zz[0], zz[1], zz[2], zz[3]};
endmodule
