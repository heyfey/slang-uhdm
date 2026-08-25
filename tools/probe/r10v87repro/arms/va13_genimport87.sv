// r10v87 arm va13 — the wildcard import written INSIDE a generate block (its
// own Surelog scope) alongside one at module level.  The gen-block instance has
// an EMPTY overridden-name set, so nothing there may be stamped.
package pg13;
  localparam int GA = 151;
  localparam int GB = 152;
endpackage

module gleaf13 #(parameter int GA = 1) (output logic [7:0] o);
  import pg13::*;                       // module level: must stamp GA
  if (1) begin : g_in
    import pg13::*;                     // gen-block level: must NOT stamp
    localparam int GA = 5;              // a gen-scope shadow of the same name
    logic [7:0] t;
    assign t = GA[7:0] + GB[7:0];
  end
  assign o = GA[7:0] + g_in.t;
endmodule

module top87 (output logic [7:0] o1, o2);
  gleaf13 #(.GA(7)) u_ov (.o(o1));
  gleaf13           u_no (.o(o2));
endmodule
