// r11u4 g2 — the AGGREGATE half and the SCOPE half.  A struct parameter cannot
// inline on the parameter object, so `reduceExpr` leaves the DEFINITION's op75
// tree; and the actual is reached from a re-passed port, an outer generate
// block and an array element as well as from the instantiating scope.
package p;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  localparam cfg_t CDEF = '{BUS: '{DAT: 32}};
  localparam cfg_t COVR = '{BUS: '{DAT: 64}};
endpackage

interface tif #(parameter p::cfg_t CFG = p::CDEF, parameter int W = 4);
  localparam int BYT = CFG.BUS.DAT / 8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module leaf  (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm (tif.mp q); logic z; assign z = q.d[0]; endmodule

// RE-PASS: the actual is this module's OWN interface port.
module mid (tif r);
  leaf  b0 (.q(r));       // named plain, actual is a re-passed PORT
  leafm b1 (.q(r.mp));    // named modport, actual is a re-passed PORT
endmodule
module midm (tif.mp r);
  leafm b2 (.q(r));       // named, actual is a re-passed modport PORT
endmodule

module top;
  tif #(.CFG(p::COVR), .W(9)) u_ov();
  tif arr [2-1:0] ();
  leaf  a0 (.q(u_ov));       // named plain, same scope
  leafm a1 (.q(u_ov.mp));    // named modport, same scope
  mid   a2 (.r(u_ov));       // re-pass, plain
  midm  a3 (.r(u_ov.mp));    // re-pass, modport
  leaf  a4 (.q(arr[0]));     // interface-ARRAY element
  if (1) begin : g
    leaf  a5 (.q(u_ov));     // actual lives OUTSIDE the instantiating gen block
    leafm a6 (.q(u_ov.mp));  // ...named modport, same
  end
endmodule
