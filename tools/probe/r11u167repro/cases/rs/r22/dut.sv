// § tpAnonStructLastParamUser167
interface bus_if;
  localparam type it_t = struct packed {
    logic [7:0] x;
    logic [7:0] y;
  };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  logic [7:0] d;
endinterface
module top (input logic a, output logic [7:0] b);
  bus_if u();
  assign u.d = a ? u.I.x : u.I.y;
  assign b = u.d;
endmodule
