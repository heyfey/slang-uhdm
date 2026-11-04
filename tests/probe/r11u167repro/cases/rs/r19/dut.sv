// § tpAnonStructLastParamUser167
module top (input logic a, output logic [7:0] b);
  localparam type u_t = union packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam u_t U = 8'd5;
  assign b = a ? U.x : U.y;
endmodule
