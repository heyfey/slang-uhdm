// r11u7 grid h4 — the nested aggregate reached through the OTHER port forms
// the r11u4 grid separates: positional plain, named modport, re-passed port,
// interface array element, generate-borne instance.
package q4;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  localparam cfg_t CDEF = '{BUS: '{DAT: 32}};
  localparam cfg_t COVR = '{BUS: '{DAT: 64}};
endpackage
interface tif #(parameter q4::cfg_t CFG = q4::CDEF, parameter int W = 4);
  localparam int BYT = CFG.BUS.DAT/8;
  logic d;
  modport mp (input d);
endinterface
module leaf  (tif q);    logic z; assign z = q.d; endmodule
module leafm (tif.mp q); logic z; assign z = q.d; endmodule
module mid   (tif r);    leaf b0 (.q(r)); endmodule
module top;
  tif #(.CFG(q4::COVR), .W(9)) u_ov();
  tif u_df();
  tif arr[1:0]();
  leaf  a0 (.q(u_ov));
  leaf  a1 (u_ov);
  leafm a2 (.q(u_ov.mp));
  leaf  a3 (.q(u_df));
  leaf  a4 (.q(arr[0]));
  mid   a5 (.r(u_ov));
  generate if (1) begin : g
    leaf a6 (.q(u_ov));
  end endgenerate
endmodule
