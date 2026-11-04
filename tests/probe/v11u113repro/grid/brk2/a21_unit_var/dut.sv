parameter int unsigned P = 5;
logic [P:0] uv;
module top (input logic [7:0] i, output logic [7:0] o);
  assign uv = i[5:0];
  assign o = uv;
endmodule
