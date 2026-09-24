// § memberAnonUnionAtKeyword134
module top(input logic [7:0] i, output logic [7:0] o);
  typedef struct packed {
    union packed signed { logic [7:0] u8; logic signed [7:0] s8; } v;
    logic tag;
  } s_t;
  s_t s;
  assign s = {i, 1'b0};
  assign o = s.v.u8;
endmodule
