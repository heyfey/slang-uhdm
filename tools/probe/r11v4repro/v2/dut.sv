// v11u4 ADVERSARIAL v2 — port forms the r11u4 grid never reached: a GENERIC
// interface port, a NESTED interface port (an interface instantiated inside an
// interface), a package-scalar default, an UNPACKED-ARRAY aggregate default,
// and a TYPE parameter.
package q;
  localparam int PBASE = 7;
  typedef struct packed { int unsigned DAT; } bus_t;
  localparam bus_t BDEF = '{DAT: 32};
  localparam bus_t BOVR = '{DAT: 64};
endpackage

interface inner_if #(parameter int IW = 5);
  logic [IW-1:0] id;
  modport mp (input id);
endinterface

interface tif #(parameter int A = q::PBASE,          // package scalar default
                parameter int B = q::PBASE * 2,      // OPERATION default
                parameter q::bus_t C = q::BDEF,      // aggregate default
                parameter int D [0:1] = '{3, 4},     // unpacked-array default
                parameter type T = logic [3:0]);     // TYPE parameter
  localparam int E = A + B;
  T d;
  inner_if #(.IW(A)) nest();                          // NESTED interface
  modport mp (input d);
endinterface

module leaf   (tif q0);        logic z; assign z = q0.d[0]; endmodule
module leafm  (tif.mp q0);     logic z; assign z = q0.d[0]; endmodule
module gen    (interface q0);  logic z; assign z = q0.d[0]; endmodule

module top;
  tif #(.A(11), .B(22), .C(q::BOVR), .D('{8, 9}), .T(logic [7:0])) u_ov();
  tif u_df();
  leaf  a0 (.q0(u_ov));       // named plain
  leafm a1 (.q0(u_ov.mp));    // named modport
  leafm a2 (u_ov.mp);         // positional modport
  gen   a3 (.q0(u_ov));       // GENERIC interface port
  gen   a4 (.q0(u_df));
endmodule
