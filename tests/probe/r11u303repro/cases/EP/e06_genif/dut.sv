// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  typedef struct packed { op_e e; logic [3:0] d; } s_t;
endpackage
module top(input logic [3:0] d, output logic o);
  if (1) begin : g
    p::s_t t;
    assign t = '{e: p::OpA, d: d};
  end
  assign o = 1'b0;
endmodule
