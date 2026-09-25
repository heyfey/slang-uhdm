// § constPathBaseAnyKind146
package p;
  typedef struct packed { logic [3:0] d; } f_t;
  typedef struct packed { f_t fifo; } s_t;
endpackage
module top();
  import p::*;
  s_t hw2reg;
  if ($bits(hw2reg.fifo.d) != 4) begin : g
    initial $error("bad");
  end
endmodule
