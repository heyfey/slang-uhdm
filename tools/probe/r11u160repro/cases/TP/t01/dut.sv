// § tpUseBindsDefDefault160
typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
module top #(parameter type dtype = d_t) (input dtype data_i, output dtype data_o);
  assign data_o = data_i;
endmodule
