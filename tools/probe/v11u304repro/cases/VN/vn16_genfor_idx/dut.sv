// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, output logic [15:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[8*i+:8] = ea[k[i] + i].fld;
  end
endmodule
