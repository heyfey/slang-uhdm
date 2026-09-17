// v4 - INTERFACE + GENERATE cells the grid did not reach: an interface ARRAY,
// a MODPORT, a net inside an interface GENERATE block, an interface net with a
// NET KEYWORD, and a generate-scope net in a module reached through a port.
interface ifa #(parameter int unsigned N = 2, parameter int unsigned D = 4) ();
  typedef logic [N-1:0] a_t [D];
  typedef logic [N-1:0] v_t;
  a_t  ga;
  wire v_t gw [2];      // NET KEYWORD + packed typedef + declarator dim
  wand v_t gd [2];      // WAND inside an interface
  generate
    if (1) begin : ib
      typedef logic [N-1:0] ia_t [D];
      ia_t iga;         // typedef + net INSIDE an interface generate block
      a_t  igb;
    end
  endgenerate
  modport mp (input ga, gw);
endinterface
module child (ifa.mp p, output logic [1:0] o);
  assign o = p.ga[0] | p.gw[0];
endmodule
module dut (output logic [1:0] o);
  ifa u0 ();
  ifa arr [2] ();       // interface ARRAY
  logic [1:0] co;
  child c0 (.p(u0.mp), .o(co));
  generate
    for (genvar gi = 0; gi < 2; gi++) begin : gl
      typedef logic [1:0] ga_t [4];
      ga_t gn;          // generate-scope net with its own unpacked typedef
      wire ga_t gwn;    // generate-scope NET KEYWORD + unpacked typedef
      assign gwn[0] = gn[0];
    end
  endgenerate
  assign o = co | u0.ga[0] | arr[0].ga[0] | gl[0].gn[0] | gl[1].gwn[0];
endmodule
