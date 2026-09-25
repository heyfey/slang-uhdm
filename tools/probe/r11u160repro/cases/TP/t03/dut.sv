// § tpUseBindsDefDefault160
module top #(parameter type dtype = logic [3:0]) (input dtype data_i, output dtype data_o);
  typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
  assign data_o = data_i;
endmodule
