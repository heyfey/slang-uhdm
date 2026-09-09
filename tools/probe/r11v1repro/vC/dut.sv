interface zif #(parameter int S = -3,
                parameter logic [7:0] B = 8'hA5,
                parameter real R = 1.5,
                parameter int unsigned U = 7);
  localparam int D = S + U;
  logic [U-1:0] d;
  modport mp (input d);
endinterface

module mp_named (zif.mp q, output logic o); assign o = q.d[0]; endmodule
module pl_named (zif    q, output logic o); assign o = q.d[0]; endmodule

module top (output logic [1:0] o);
  zif #(.S(-9), .B(8'h5A), .R(2.5), .U(12)) u ();
  mp_named a0 (.q(u.mp), .o(o[0]));
  pl_named a1 (.q(u),    .o(o[1]));
endmodule
