// § impEnumParamRefNoSize409
package p;
  typedef enum logic [2:0] { A, B, C } e_t;
  parameter e_t P = C;
  typedef enum { X, Y } f_t;
  localparam f_t L = Y;
endpackage
import p::*;
module top (output [31:0] o);
  assign o = P + L;
endmodule
