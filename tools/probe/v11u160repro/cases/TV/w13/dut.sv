// § tpUseBindsDefDefault160
typedef struct packed { logic [3:0] op; } d_t;
module leaf #(parameter type dtype = d_t) (input dtype data_i, output dtype data_o);
  dtype q;
  assign q = data_i;
  assign data_o = q;
endmodule
module top (input logic [7:0] a, output logic [7:0] b);
  typedef struct packed { logic [7:0] op; } d_t;
  leaf #(.dtype(d_t)) u (.data_i(a), .data_o(b));
endmodule
