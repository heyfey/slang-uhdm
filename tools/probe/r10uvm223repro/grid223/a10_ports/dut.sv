package p223m;
   int    mv_p223;
   string mv_q223;
endpackage

interface if223m(input logic clk223, output logic rdy223);
   import p223m::*;
   logic w223;
   int   own223m;
endinterface

module top223m;
   logic c223, r223;
   if223m u_m223(c223, r223);
endmodule
