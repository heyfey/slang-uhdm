// § genConnTrailSelChain205: a case-generate instance with a localparam-indexed member select
package rp;
  typedef struct packed { logic [3:0] a; logic b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top #(parameter int M = 1) (input rp::r_t w, output logic o);
  localparam int L = 2;
  case (M)
    1: begin : c1
      sub u(.i(w.a[L]), .o(o));
    end
    default: begin : cd
      sub u(.i(w.b), .o(o));
    end
  endcase
endmodule
