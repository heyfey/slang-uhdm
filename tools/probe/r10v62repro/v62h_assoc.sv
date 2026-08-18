// v62h — THE NO-STAMP HOLE.  `isSharedAliasTs(t, ts)` resolves `typedefTs` by
// the CURRENT specialization's TypeAliasType symbol.  In a SECOND
// specialization that lookup misses by construction (that is the premise of
// § defBodyTypedefSiteShare62), so a typespec handed back by the new
// site-keyed arm is judged "fresh" and the four § sharedAliasNoStamp41 sites
// are free to RE-SPAN / RE-INSTANCE the DEF's shared object -- which every
// instance and the def listing point at.  Shape: a module-local typedef used
// as an ASSOCIATIVE-ARRAY INDEX TYPE and as an array element, in a module with
// two specializations.
module as62 #(parameter int W = 4) (input logic clk, output logic [7:0] z);
  typedef logic [7:0] idx_t;                       // vector typedef
  typedef enum logic [1:0] { HA, HB, HC } h_e;
  typedef struct packed { h_e op; logic [1:0] sz; } h_t;

  logic       amap [idx_t];        // ASSOC index type = module-local typedef
  logic       amap2 [h_t];         // ASSOC index type = module-local struct td
  idx_t       varr [0:1];          // unpacked array of the typedef
  h_t         harr [0:2];
  idx_t       q;
  h_t         hv;

  assign z = q ^ {6'b0, harr[1].sz} ^ {6'b0, hv.sz} ^ {7'b0, (hv.op == HB)};
endmodule

module top62h (input logic clk, output logic [15:0] o);
  logic [7:0] za, zb;
  as62 #(.W(4)) u_a (.clk(clk), .z(za));
  as62 #(.W(8)) u_b (.clk(clk), .z(zb));
  assign o = {za, zb};
endmodule
