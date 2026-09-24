// v11u71 x6 — THE INTERFACE HOME, DEEPER.  An interface instantiated INSIDE a
// module gen block, an interface ARRAY, and a namesake living in the
// instantiating module's GEN block (which `bindVariable` recurses PAST) versus
// one in the module BODY (which it searches).
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 300};
endpackage

interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] body_t;
  if (1) begin : gi
    logic [31:0] loc;      // interface gen-local, no namesake
    logic [31:0] inbody;   // namesake in the MODULE body (9 bits)
    logic [31:0] ingen;    // namesake in the instantiating GEN block (6 bits)
    assign loc    = C.n;
    assign inbody = C.n;
    assign ingen  = C.n;
    assign body_t = C.n;   // interface-body target from the gen scope
  end
endinterface

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  logic [8:0] inbody;                  // module-body namesake, 9 bits
  ifc u_top ();
  if (1) begin : gwrap
    logic [5:0] ingen;                 // a GEN-scope namesake: not searched
    ifc u_in ();                       // interface inside a gen block
    assign ingen = 6'd0;
  end
  ifc u_arr [0:1] ();                  // interface ARRAY
  assign o = {32'd0, u_top.gi.loc} ^ {32'd0, u_top.gi.inbody}
           ^ {32'd0, u_top.gi.ingen} ^ {32'd0, u_top.body_t}
           ^ {32'd0, gwrap.u_in.gi.loc} ^ {32'd0, u_arr[0].gi.loc}
           ^ {32'd0, u_arr[1].gi.inbody};
  assign inbody = 9'd0;
endmodule
