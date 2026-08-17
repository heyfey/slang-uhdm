// r10earl59 VERIFIER arm W3 — the PORT/NET LISTING battery the brief names:
// non-ANSI ports, .name()/.*/positional/UNCONNECTED connections, an ARRAY of
// instances, a width-parameter override, an INTERFACE port + MODPORT, a port
// driven from only ONE generate arm, and an UNINSTANTIATED module carrying the
// same shape (DEF view only).
interface w3if;
  logic [3:0] d;
  logic [3:0] q;
  modport mp (input d, output q);
endinterface

module w3nonansi (clk, din, o_na, io_na);       // NON-ANSI header
  input        clk;
  input  [3:0] din;
  output [3:0] o_na;
  inout  [3:0] io_na;
  wire   [3:0] o_na;
  wire   [3:0] mn_src;
  logic        me;
  assign mn_src = din;
  assign me     = din[0];
  if (1) begin : g_a
    if (1) begin : g_b
      wire [3:0] lb;
      assign lb    = mn_src;
      assign o_na  = me ? 4'b0 : lb;     // non-ANSI output net, d2, operation
      assign io_na = lb | mn_src;        // non-ANSI inout net, d2, operation
    end
  end
endmodule

module w3ifport (w3if.mp p, input [3:0] din);    // INTERFACE port + MODPORT
  wire [3:0] mn_l;
  assign mn_l  = din;
  assign mn_l2 = din;   // creates the module-level IMPLICIT net mn_l2
  if (1) begin : g_a
    if (1) begin : g_b
      wire [3:0] lb;
      assign lb  = mn_l;
      assign p.q = lb | mn_l;            // modport member LHS (hier ref)
      assign mn_l2 = lb | mn_l;          // module-level IMPLICIT net, d2
    end
  end
endmodule

module w3arm #(parameter int W = 4) (
  input  [W-1:0] din,
  output [W-1:0] o_w,
  output [3:0]   o_onearm,
  output [3:0]   o_unconn
);
  wire [W-1:0] mn_src;
  logic        me;
  assign mn_src = din;
  assign me     = din[0];
  if (W == 4) begin : g_four
    if (1) begin : g_in
      wire [W-1:0] lb;
      assign lb  = mn_src;
      assign o_w = me ? {W{1'b0}} : lb;        // width-PARAM port net, d2
      assign o_onearm = lb[3:0] | mn_src[3:0]; // driven in only THIS arm
    end
  end else begin : g_other
    if (1) begin : g_in2
      wire [W-1:0] lc;
      assign lc  = mn_src;
      assign o_w = me ? {W{1'b0}} : lc;
    end
  end
endmodule

// UNINSTANTIATED: same shape, DEF listing only.
module w3never (input [3:0] din, output [3:0] o);
  wire [3:0] mn_src;
  logic      me;
  assign mn_src = din;
  assign me     = din[0];
  if (1) begin : g_a
    if (1) begin : g_b
      wire [3:0] lb;
      assign lb = mn_src;
      assign o  = me ? 4'b0 : lb;
    end
  end
endmodule

module a1;
  wire       clk;
  wire [3:0] din;
  wire [3:0] o1, io1, o2, o3, o4, o5, o6, o7, o8;
  wire [7:0] w8din, w8o;
  w3if      the_if ();
  w3nonansi u_na  (clk, din, o1, io1);                 // POSITIONAL
  w3ifport  u_ifp (.p(the_if.mp), .din(din));          // interface port
  w3arm #(.W(4)) u_a4 (.din(din), .o_w(o2), .o_onearm(o3), .o_unconn());
  w3arm #(.W(8)) u_a8 (.din(w8din), .o_w(w8o), .o_onearm(o4), .o_unconn(o5));
  w3arm     u_dot (.*, .o_w(o6), .o_onearm(o7), .o_unconn(o8));
  // ARRAY of instances, the 127-copy shape
  wire [7:0] arr_o, arr_a, arr_b;
  w3arm u_arr [0:1] (.din(din), .o_w(arr_o), .o_onearm(arr_a), .o_unconn(arr_b));
endmodule
