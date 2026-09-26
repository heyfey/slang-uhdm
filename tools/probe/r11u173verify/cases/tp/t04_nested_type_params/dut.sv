// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — a type parameter whose struct holds another type parameter
module top (input logic a, output logic [3:0] b);
  localparam type in_t = struct packed {
    logic [3:0] x;
  };
  localparam type out_t = struct packed {
    in_t i;
    logic [3:0] y;
  };
  localparam out_t O = '{i: '{x: 4'd7}, y: 4'd8};
  assign b = a ? O.i.x : O.y;
endmodule
