// § tpUseBindsDefDefault160
typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
module top #(parameter type dtype = u_t) (input dtype data_i, output dtype data_o);
  assign data_o = data_i;
endmodule
