// r11u4 g1 — VALUE KINDS x PORT/CONNECTION FORM on a singly-parameterized
// scalar interface.  Reads: each port view's param_assign Rhs value+span and
// its vpiOverriden stamp.
interface tif #(parameter int PI = 3,
                parameter int NI = -3,
                parameter logic [7:0] HX = 8'hA5,
                parameter real RE = 2.5,
                parameter string ST = "def");
  localparam int BYT = PI * 2;
  logic [PI-1:0] d;
  modport mp (input d);
endinterface

module leaf  (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  tif #(.PI(9), .NI(-9), .HX(8'h5A), .RE(4.5), .ST("ovr")) u_ov();
  tif u_df();
  leaf  a0 (.q(u_ov));      // named plain
  leaf  a1 (u_ov);          // positional plain
  leafm a2 (.q(u_ov.mp));   // named modport
  leafm a3 (u_ov.mp);       // positional modport
  leaf  a4 (.q(u_df));      // named plain, NO override to inherit
endmodule
