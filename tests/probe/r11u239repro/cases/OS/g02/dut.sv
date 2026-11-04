// § genConnOpSelIdxScope239
// (pass 236 decode g02, Earlgrey #121994)
module sub (input logic a_i, output logic o);
  assign o = a_i;
endmodule
module top (input logic r, input logic [1:0] sel, input logic [3:0] v, output logic [3:0] o);
  for (genvar bank = 0; bank < 4; bank++) begin : gen_b
    sub u_s (.a_i(r & (sel == bank) & v[bank]), .o(o[bank]));
  end
endmodule
