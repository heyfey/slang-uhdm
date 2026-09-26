// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — a packed anonymous union type parameter, two value parameters
module top (input logic a, output logic [7:0] b);
  localparam type u_t = union packed {
    logic [7:0] w;
    logic [7:0] v;
  };
  localparam u_t U0 = 8'h12;
  localparam u_t U1 = 8'h34;
  assign b = a ? U0.w : U1.v;
endmodule
