// § genCaEnumQualWholeSpan303
package p;
  typedef enum logic [2:0] {OpA = 3'h0, OpB = 3'h4} op_e;
  typedef struct packed { op_e e; logic [3:0] d; } s_t;
  typedef struct packed { s_t s; logic b; } w_t;
endpackage
module top(input logic [3:0] d, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    p::w_t t;
    assign t = '{s: '{e: p::OpB, d: d}, b: 1'b1};
  end
  assign o = 1'b0;
endmodule
