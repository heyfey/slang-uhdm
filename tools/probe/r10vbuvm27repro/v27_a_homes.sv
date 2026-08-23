// r10vbuvm27 ARM A -- $bits(<binary with select left>) in EVERY HOME.
package pA;
  typedef struct packed { bit [3:0] hi; bit [7:0] lo; } sp_t;
  byte unsigned pdyn [];
  bit  [31:0]   pv32;
  logic [7:0]   ppk4 [4];

  class CA;
    byte unsigned dyn [];
    bit [31:0]    v32;
    logic [7:0]   pk4 [4];
    byte unsigned be;
    int r; int i;
    function void inblk();                  // a01 in-block
      r = $bits(dyn[i] & be);
      r = $bits(pk4[i] & be);
    endfunction
    extern function void oob();             // a02 OUT OF BLOCK
    extern task oobt();
    static function void stat();            // a03 static method
      byte unsigned lb; int lr; int li;
      logic [7:0] lpk [4];
      lr = $bits(lpk[li] & lb);
      $display("%0d", lr);
    endfunction
    task tsk();                             // a04 class task
      r = $bits(dyn[i] & be);
    endtask
  endclass
  function void CA::oob();
    r = $bits(dyn[i] & be);                 // OOB: golden KEEPS (Reduce::No)
    r = $bits(pk4[i] & be);
    r = $bits(dyn[i]);
  endfunction
  task CA::oobt();
    r = $bits(pk4[i] & be);
  endtask

  function int pfun(int i);                 // a05 package function
    byte unsigned be; int r;
    r = $bits(pdyn[i] & be);
    r = $bits(ppk4[i] & be);
    return r;
  endfunction
  task ptsk(int i);                         // a06 package task
    byte unsigned be; int r;
    r = $bits(pdyn[i] & be);
    $display("%0d", r);
  endtask
endpackage

interface ifA;                              // a07 interface
  import pA::*;
  logic [7:0] idyn [4];
  byte unsigned ibe;
  int ir, ii;
  function int ifun();
    return $bits(idyn[ii] & ibe);
  endfunction
  initial ir = $bits(idyn[ii] & ibe);
endinterface

program prgA;                               // a08 program
  import pA::*;
  logic [7:0] gpk [4];
  byte unsigned gbe;
  int gr, gi;
  initial gr = $bits(gpk[gi] & gbe);
endprogram

module vA;
  import pA::*;
  logic [7:0]   mpk4 [4];
  byte unsigned mdyn [];
  bit  [31:0]   mv32;
  byte unsigned mbe;
  int mi, mr;
  wire [63:0] wq;
  assign wq = $bits(mpk4[1] & mbe);                 // a09 cont_assign
  localparam int LPA = $bits(mpk4[1] & 8'h0F);      // a10 localparam
  parameter  int PPA = $bits(mv32[3] & 8'h0F);      // a11 parameter
  function int mfun(int k);                         // a12 module function
    return $bits(mpk4[k] & mbe);
  endfunction
  task mtsk(int k);                                 // a13 module task
    mr = $bits(mpk4[k] & mbe);
  endtask
  initial begin                                     // a14 initial
    mr = $bits(mdyn[mi] & mbe);
  end
  always @(mi) mr = $bits(mpk4[mi] & mbe);          // a15 always
  generate                                          // a16 generate
    genvar gv;
    for (gv = 0; gv < 2; gv++) begin : gblk
      localparam int GLP = $bits(mpk4[gv] & 8'h0F);
      wire [7:0] gw;
      assign gw = $bits(mpk4[gv] & 8'h0F);
    end
  endgenerate
  if (1) begin : cblk                               // a17 generate-if
    localparam int CLP = $bits(mpk4[0] & 8'h0F);
  end
  initial begin
    CA c = new(); c.inblk(); c.oob(); c.tsk(); c.oobt(); CA::stat();
    mr = pfun(0); ptsk(0); mr = mfun(0); mtsk(0);
    $display("%0d %0d %0d %0d %0d", mr, LPA, PPA, gblk[0].GLP, cblk.CLP);
  end
endmodule
