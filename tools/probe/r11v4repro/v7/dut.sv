// r11v4 ADVERSARIAL v7 — face (C)'s TYPESPEC-DROP boundary.  Which OPERATION
// defaults keep their vpiTypespec on a port view and which lose it?
//   M1  explicitly TYPED operation default            (logic [7:0] = a+b)
//   M2  untyped int operation default                 (int = a+b)
//   M3  operation default that DEPENDS on an OVERRIDDEN parameter
//   M4  operation default over a package localparam
//   M5  a plain literal (control: must KEEP its typespec)
//   M6  a SIGNED typed operation default
package w;
  localparam int PB = 5;
endpackage

interface tif #(parameter int A = 3,
                parameter logic [7:0] M1 = 8'hA0 + 8'h05,
                parameter int         M2 = 1 + 2,
                parameter int         M3 = A * 4,
                parameter int         M4 = w::PB + 1,
                parameter int         M5 = 7,
                parameter bit signed [15:0] M6 = 16'sd9 - 16'sd2);
  logic [A-1:0] d;
  modport mp (input d);
endinterface

module leaf  (tif q);    logic z; assign z = q.d[0]; endmodule
module leafm (tif.mp q); logic z; assign z = q.d[0]; endmodule

module top;
  tif #(.A(9), .M1(8'h11), .M2(22), .M3(33), .M4(44), .M5(55), .M6(16'sd66)) u_ov();
  tif u_df();
  leaf  a0 (.q(u_ov));      // named plain, overridden instance
  leaf  a1 (u_ov);          // positional plain
  leafm a2 (.q(u_ov.mp));   // named modport  (the exception)
  leaf  a3 (.q(u_df));      // named plain, un-overridden instance
endmodule
