module dut;
  localparam int W = 8;
  localparam type a_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
  localparam type b_t = union  packed { logic [11:0] p; logic [11:0] q; };
  localparam type c_t = struct        { logic [W-1:0] u; int v; };
  localparam a_t A = '{x: 8'd1, y: 4'd2};
  localparam b_t B = 12'd3;
  localparam c_t C = '{u: 8'd4, v: 5};
  logic [11:0] z;
  int w;
  initial begin z = A ^ B; w = C.v; end
endmodule
