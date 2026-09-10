// r11u4 g3 — the two def flavours the `ifaceDefaultScope` RANGE gate exempts:
// a GENERATE-bearing interface and a def whose override TEXTS differ across
// instances (Surelog uniquifies pre-elab, on the text).  Does the PARAM_ASSIGN
// half exempt them too, or only the named-modport cell?
interface gif #(parameter int W = 4);
  logic [W-1:0] d;
  generate if (W > 2) begin : gg logic extra; end endgenerate
  modport mp (input d);
endinterface

interface tif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leafg  (gif q);    logic z; assign z = q.d[0]; endmodule
module leafgm (gif.mp q); logic z; assign z = q.d[0]; endmodule
module leaft  (tif q);    logic z; assign z = q.d[0]; endmodule
module leaftm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  localparam int WW = 9;
  gif #(.W(9)) u_g();
  leafg  c0 (.q(u_g));        // gen-bearing def, named plain
  leafgm c1 (.q(u_g.mp));     // gen-bearing def, named modport
  // TEXT-multi: the same folded value written two ways -> two Surelog modules.
  tif #(9)     u_t1();
  tif #(.W(WW)) u_t2();
  leaft  c2 (.q(u_t1));       // text-multi def, named plain
  leaft  c3 (u_t2);           // text-multi def, positional plain
  leaftm c4 (.q(u_t1.mp));    // text-multi def, named modport
endmodule
