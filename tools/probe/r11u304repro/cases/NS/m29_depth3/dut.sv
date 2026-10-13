// § hpOpIdxNestedSelByPath304
module leaf (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld;} el_t;
  el_t [3:0] ea;
  assign ea = '0;
  assign o = ea[k[0] + 1].fld;
endmodule
module mid (input logic [1:0] k, output logic [7:0] o);
  leaf l(.k(k), .o(o));
endmodule
module top (input logic [1:0] k, output logic [7:0] o);
  mid m(.k(k), .o(o));
endmodule
