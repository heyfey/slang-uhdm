// § tpUseBindsDefDefault160
typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
module child #(parameter type dtype = logic) (input dtype data_i, output dtype data_o);
  assign data_o = data_i;
endmodule
module top (input d_t i, output d_t o);
  child #(.dtype(d_t)) c (.data_i(i), .data_o(o));
endmodule
