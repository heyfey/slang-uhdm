// § bodyTypeParamDefaultBound160
module leaf (input logic [15:0] d, output logic [15:0] o);
  localparam type my_t = struct packed { logic [3:0] a; logic [3:0] b; };
  my_t [1:0] arr;
  assign arr = d;
  assign o = arr;
endmodule
module top (input logic [15:0] d, output logic [15:0] o, output logic [15:0] o2);
  leaf u1 (.d(d), .o(o));
  leaf u2 (.d(d), .o(o2));
endmodule
