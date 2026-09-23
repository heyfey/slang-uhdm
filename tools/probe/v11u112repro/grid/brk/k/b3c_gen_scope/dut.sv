module m(output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam type T = struct packed { logic [3:0] a; };
    T x;
    T [1:0] p;
    assign x = i; assign p = '0;
    assign o[i*4 +: 4] = x.a ^ p[0].a;
  end
endmodule
