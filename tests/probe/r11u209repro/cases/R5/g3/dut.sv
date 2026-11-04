// § genConnTrailSelChain205: a generate-scope instance reading an interface member select
interface bus_if;
  logic [3:0] d;
endinterface
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module top (input logic [3:0] i, output logic [1:0] o);
  bus_if b();
  assign b.d = i;
  for (genvar k = 0; k < 2; k++) begin : gen_b
    leaf u (.x(b.d[k]), .y(o[k]));
  end
endmodule
