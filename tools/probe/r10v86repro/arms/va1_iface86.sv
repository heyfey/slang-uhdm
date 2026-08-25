// r10v86 va1 — THE INTERFACE HOME (absent from the implementer's g3) plus a
// PROGRAM home, x 1..3 instances.  GOLDEN = Surelog.  MEASUREMENT ONLY.
interface v86_if #(parameter int AddrW = 17, parameter int OVP = 4) ();
  localparam int P = 8;
  localparam int W = 5;
  localparam logic [7:0] LW = 8'd3;
  localparam signed [7:0] SG = 8'sd6;

  localparam logic[AddrW-1:0] i_add = ~(('h1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] i_mul = ~(('h1 << (P * W)) - 1'b1);
  localparam logic[AddrW-1:0] i_bar = ~(('h1 << P) - 1'b1);
  localparam logic[AddrW-1:0] i_ovp = ~(('h1 << (OVP + W)) - 1'b1);
  localparam logic[AddrW-1:0] i_sg  = ~(('h1 << (SG + 1)) - 1'b1);
  localparam logic[AddrW-1:0] i_ng  = ~(('h1 << (~LW)) - 1'b1);
  localparam logic[AddrW-1:0] i_d3  = ~(('h1 << (((P + W) * 2) - 1)) - 1'b1);
  if (1) begin : gi
    localparam logic[AddrW-1:0] i_gif = ~(('h1 << (P + W)) - 1'b1);
  end
  for (genvar gj = 0; gj < 2; gj++) begin : gf
    localparam logic[AddrW-1:0] i_gfr = ~(('h1 << (P + W + gj)) - 1'b1);
  end
endinterface

module v86_ifuser (v86_if vif);
  localparam int Q = 3;
  localparam logic[16:0] u_add = ~(('h1 << (Q + 2)) - 1'b1);
endmodule

module top86_v1 ();
  v86_if #(.AddrW(17), .OVP(4)) w0 ();
  v86_if #(.AddrW(18), .OVP(6)) w1 ();
  v86_if #(.AddrW(19), .OVP(9)) w2 ();
  v86_ifuser u0 (.vif(w0));
  v86_ifuser u1 (.vif(w1));
endmodule
