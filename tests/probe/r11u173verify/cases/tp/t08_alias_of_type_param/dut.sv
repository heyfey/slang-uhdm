// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — a type parameter aliasing another type parameter's struct, value parameters of both
module top (input logic a, output logic [3:0] b);
  localparam type a_t = struct packed {
    logic [3:0] x;
  };
  localparam type b_t = a_t;
  localparam a_t A = '{x: 4'd1};
  localparam b_t B = '{x: 4'd2};
  assign b = a ? A.x : B.x;
endmodule
