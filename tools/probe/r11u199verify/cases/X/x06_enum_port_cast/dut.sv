// § tpCaPortNetIsVar194v § castOperandLeafElab193 § connCastTsNamedByPort193
typedef enum logic [2:0] { E0, E1, E2 } e_t;
module sub #(type T = logic [2:0]) (input logic [2:0] si, output wire T so);
  assign so = T'(si);
endmodule
module top (input logic [5:0] i, output e_t o1, output e_t o2);
  logic [5:0] r;
  assign r = i;
  sub #(.T(e_t)) v1 (.si(3'(r)), .so(o1));
  sub #(.T(e_t)) v2 (.si(3'(r >> 3)), .so(o2));
endmodule
