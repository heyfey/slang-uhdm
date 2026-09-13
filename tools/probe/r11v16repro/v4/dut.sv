// v4 — ONE, TWO and THREE instances of the same child reading the member,
// plus the child's own def listing.  The shared-slot replacement runs once per
// elaborated copy off ONE def object.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t c;
    c.n    = 3;
    c.base = 64'h1000;
    return c;
  endfunction
endpackage

module kid (output wire [31:0] o);
  localparam p::cfg_t C = p::build();
  assign o = C.n;
endmodule

module dut (output wire [31:0] o1, o2, o3, o_top);
  localparam p::cfg_t CFG = p::build();
  assign o_top = CFG.n;
  kid u1 (o1);
  kid u2 (o2);
  kid u3 (o3);
endmodule
