// r11u36 GOLDEN GRID 1 — interface-ARRAY element views: presence of
// vpiParameter / vpiParamAssign on the per-element port view.
package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
  localparam cfg_t DEF = '{A: 1, B: 2};
  localparam cfg_t OVR = '{A: 9, B: 8};
endpackage

interface tif #(parameter int W = 8, parameter p::cfg_t CFG = p::DEF)
              (input logic clk);
  localparam int BYT = W / 8 + CFG.A;
  logic         vld;
  logic [W-1:0] dat;
  modport mp (input clk, output vld, output dat);
  modport sb (input clk, input  vld, input  dat);
endinterface

// (a) whole-array port, modport-qualified, [msb:lsb] form
module ma (tif.mp m [1:0]);
  assign m[0].vld = 1'b1;
  assign m[1].vld = 1'b0;
endmodule

// (b) whole-array port, modport-qualified, SIZE form
module msz (tif.mp m [2]);
  assign m[0].vld = 1'b1;
endmodule

// (c) whole-array port, PLAIN (no modport)
module mpl (tif m [1:0]);
  assign m[0].vld = 1'b1;
endmodule

// (d) scalar port taking ONE element (bit-select actual)
module mone (tif.mp q);
  assign q.vld = 1'b1;
endmodule

// (e) array port at an INTERFACE holder
interface ih (tif.mp hm [1:0]);
  logic z;
  assign hm[0].vld = 1'b1;
endinterface

// (f) 4-wide array port
module m4 (tif.mp w [3:0]);
  assign w[0].vld = 1'b1;
endmodule

// (g) 1-wide array port
module m1 (tif.mp u [0:0]);
  assign u[0].vld = 1'b1;
endmodule

module top (input logic clk, output logic o);
  tif #(.W(32), .CFG(p::OVR)) arr [1:0] (.clk(clk));   // OVERRIDDEN holder array
  tif                          dfl [1:0] (.clk(clk));  // DEFAULT holder array
  tif #(.W(32), .CFG(p::OVR)) wid [3:0] (.clk(clk));
  tif #(.W(32), .CFG(p::OVR)) one [0:0] (.clk(clk));

  ma   a0 (.m(arr));      // (a) overridden actual
  ma   a1 (.m(dfl));      // (a) default actual
  msz  a2 (.m(arr));      // (b)
  mpl  a3 (.m(arr));      // (c)
  mone a4 (.q(arr[0]));   // (d)
  ih   a5 (.hm(arr));     // (e)
  m4   a6 (.w(wid));      // (f)
  m1   a7 (.u(one));      // (g)

  for (genvar gi = 0; gi < 1; gi++) begin : g
    ma a8 (.m(arr));      // (a) inside a generate loop
  end

  assign o = arr[0].vld;
endmodule
