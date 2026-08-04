module sub #(parameter int W = 4)(output logic [W-1:0] o);
  if (1) begin : gbf
    localparam bit [3:0] IV = 4'h0;
    localparam logic [3:0] LV = 4'h1;
    assign o = IV | LV;
  end
endmodule
module top(output logic [3:0] o);
  sub u(o);
endmodule
