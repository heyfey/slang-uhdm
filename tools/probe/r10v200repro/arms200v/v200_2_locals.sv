// r10v200 break arm 2 — the DECLARATION SHAPES a clone's own locals can take:
// a function-local localparam in a later local's range, packed multi-dim,
// UNPACKED dimensions, a struct member, and a typedef'd local.
package pv2;
  parameter WL = 5;
  typedef struct packed { logic [WL:0] f; } sv2_t;
  typedef logic [WL:0] tv2_t;
  function logic [WL:0] f2(input logic [WL:0] a, input logic [WL:0][WL:0] m);
    localparam int FLP = 3;
    logic [FLP:0] locflp;
    logic [WL:0]  locpk;
    logic [WL:0]  locarr [WL:0];
    logic [WL:0][WL:0] locmd;
    sv2_t locst;
    tv2_t loctd;
    locflp = a[FLP:0];
    locpk = a;
    locarr[0] = a;
    locmd = m;
    locst.f = a;
    loctd = a;
    f2 = locpk;
  endfunction
  task t2(input logic [WL:0] a, output logic [WL:0] b);
    logic [WL:0] tloc;
    tloc = a;
    b = tloc;
  endtask
endpackage

package pv2imp;
  import pv2::*;
endpackage

module topv2;
  import pv2::*;
  initial $display(WL);
endmodule
