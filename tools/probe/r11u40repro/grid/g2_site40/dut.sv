// r11u40 g2_site40 — THE SITE INSIDE THE CHILD.
// One child (kid40) carrying a range bound built from its own parameter W at
// every site a bound can sit at.  It is instantiated TWICE:
//   u_hop  — W overridden ACROSS THE INTERFACE-PORT HOP (s.CFG.BUS.DAT = 32)
//   u_mod  — W overridden by the parent's own module parameter (20)  [CONTROL]
// The two arms carry DIFFERENT values, so the design-level typespec POOL's
// multiset attributes every folded cell to its arm without an owner chain.
package p40;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface tif40 #(parameter p40::cfg_t CFG = '{BUS: '{DAT: 32}});
  logic [CFG.BUS.DAT-1:0] data;
  modport sub (input data);
endinterface

module grand40 #(parameter int unsigned W2 = 4) (input logic clk);
  logic [W2-1:0] gv2;                                 // SITE: a GRANDCHILD's var
  always_ff @(posedge clk) gv2 <= '0;
endmodule

module kid40 #(parameter int unsigned W = 8)
             (input logic clk, input logic [W-1:0] pin);   // SITE: a PORT dim
  logic [W-1:0]  bodyvar;                             // SITE: a body VARIABLE
  wire  [W-1:0]  bodynet;                             // SITE: a body NET
  logic [7:0]    memsz [W];                           // SITE: an unpacked SIZE dim
  logic [7:0]    memrg [W-1:0];                       // SITE: an unpacked RANGE dim
  typedef logic [W-1:0] tdef_t;                       // SITE: a body TYPEDEF
  tdef_t tdv;
  typedef struct packed { logic [W-1:0] m; } st_t;    // SITE: a struct MEMBER dim
  st_t stv;
  localparam int unsigned LP = W - 1;                 // SITE: a body LOCALPARAM
  logic [LP:0] lpv;
  if (1) begin : gb                                   // SITE: a GENERATE block
    logic [W-1:0] genv;
  end
  function automatic logic [W-1:0] fn(input logic [W-1:0] a);  // SITE: a FUNCTION
    logic [W-1:0] fnl;
    fnl = a;
    fn  = fnl;
  endfunction
  grand40 #(.W2(W)) u_g (.clk(clk));                  // SITE: RE-PASSED to a grandchild
  assign bodynet = pin;
  always_ff @(posedge clk) begin
    bodyvar <= pin;
    stv.m   <= fn(pin);
    lpv     <= '0;
    tdv     <= '0;
  end
endmodule

module w_hop40 (input logic clk, tif40.sub s);
  kid40 #(.W(s.CFG.BUS.DAT)) u_hop (.clk(clk), .pin('0));
endmodule

module w_mod40 #(parameter int unsigned TW = 20) (input logic clk);
  kid40 #(.W(TW)) u_mod (.clk(clk), .pin('0));
endmodule

module g2_site40 (input logic clk);
  tif40 s();
  w_hop40 u_h (.clk(clk), .s(s.sub));
  w_mod40 u_m (.clk(clk));
endmodule
