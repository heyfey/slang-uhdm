// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — a value parameter and a function formal of the type (the formal relocates)
module top (input logic a, output logic [3:0] b);
  localparam type it_t = struct packed {
    logic [3:0] x;
    logic [3:0] y;
  };
  localparam it_t I = '{x: 4'd3, y: 4'd4};
  function automatic logic [3:0] pick(it_t v);
    return v.x;
  endfunction
  assign b = a ? pick(I) : I.y;
endmodule
