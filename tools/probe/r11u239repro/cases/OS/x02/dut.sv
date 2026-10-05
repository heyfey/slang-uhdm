// § genConnOpSelIdxScope239
// positional connection, a two-dimensional select, an interface instance port
interface ifc; logic x; endinterface
module sub (input logic a_i, output logic o);
  assign o = a_i;
endmodule
module top (input logic r, input logic [1:0][3:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (r ^ v[1][i], o[i]);
    ifc u_if ();
  end
endmodule
