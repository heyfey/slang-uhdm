package pk;
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
endpackage
module sub #(parameter type t_p = pk::it_t) (output logic [11:0] o);
  localparam t_p I = '{x: 8'd1, y: 4'd2};
  assign o = I;
endmodule
module dut;
  logic [11:0] a;
  sub u0 (.o(a));
endmodule
