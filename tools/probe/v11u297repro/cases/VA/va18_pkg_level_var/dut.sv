// § varDeclInitMovesSharedTsEnd297
package p;
  typedef struct packed { logic [1:0] a; logic b; } t_t;
  var t_t g = 3'b011;
endpackage
module dut(output logic [2:0] o);
  import p::*;
  var t_t x = 3'b100;
  assign o = x ^ g;
endmodule
