// § tpUseBindsDefDefault160
package p;
  typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
endpackage
typedef struct packed { logic [3:0] op; logic [7:0] a; } d_t;
module top #(parameter type dtype = p::d_t) (input dtype data_i, output dtype data_o);
  assign data_o = data_i;
endmodule
