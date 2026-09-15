package pa;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  parameter int unsigned S1 = 40 - 18;      // INT chain
  parameter e_t          EP = E2;
  parameter              STR = "abc";
  parameter real         RP  = 1.5;
  parameter logic [7:0]  V8  = 8'hA5;
  parameter int unsigned Q1  = S1;          // pkg param naming a pkg param
endpackage
package pb;
  import pa::*;
  parameter int unsigned R1 = pa::S1;       // CROSS-package name
  parameter int unsigned R2 = S1 + 0;
endpackage
interface ifc import pa::*; #(parameter int unsigned IP = S1) (); endinterface
module mm import pa::*; #(
  parameter int unsigned M1 = S1,
  parameter pa::e_t      M2 = EP,
  parameter              M3 = STR,
  parameter real         M4 = RP,
  parameter logic [7:0]  M5 = V8,
  parameter int unsigned M6 = pb::R1,
  parameter int unsigned M7 = Q1
) ();
  localparam int unsigned LM1 = S1;
endmodule
module top;
  mm u();
  ifc ii();
endmodule
