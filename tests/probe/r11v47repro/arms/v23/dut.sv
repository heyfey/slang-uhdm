module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [3:0] y; })
  (output logic [11:0] o);
  localparam it_t I = 12'd5;
  assign o = I;
endmodule
module dut;
  logic [11:0] z [0:2];
  genvar gi;
  generate
    for (gi = 0; gi < 3; gi++) begin : gb
      sub u (.o(z[gi]));
    end
  endgenerate
endmodule
