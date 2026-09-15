module sub #(parameter type t = struct packed { logic [7:0] a; logic [3:0] b; })
  (output logic [11:0] o);
  localparam t I = 12'd9;
  assign o = I;
endmodule
module mid #(parameter type u = struct packed { logic [5:0] p; logic [5:0] q; })
  (output logic [11:0] o);
  sub #(.t(u)) s0 (.o(o));
endmodule
module dut;
  logic [11:0] a;
  mid m0 (.o(a));
endmodule
