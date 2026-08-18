
interface ifc;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
  end
  logic [7:0] d;
endinterface
module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  ifc i0();
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
