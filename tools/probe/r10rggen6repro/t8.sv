module bf #(parameter bit [3:0] IVP = 4'h0)(output logic [3:0] q);
  assign q = IVP;
endmodule
module sub(output logic [3:0] o, output logic [3:0] p);
  if (1) begin : gbf
    localparam bit [3:0] IV = 4'h0;
    localparam bit [3:0] IW = 4'h2;
    bf #(.IVP(IV)) u_bf(o);
    assign p = IW;
  end
endmodule
module top(output logic [3:0] o, output logic [3:0] p);
  sub u(o, p);
endmodule
