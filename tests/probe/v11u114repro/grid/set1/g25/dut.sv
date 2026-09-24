// face-1 elaborated module copy read in the elaborated module (top view)
package q2;
  typedef struct packed { logic [3:0] a; logic [7:0] v; } e_t;
  parameter e_t C = '{a: 4'h1, v: {4'h5, 4'h3}};
endpackage
module sub import q2::*; #(parameter int W=8) (output logic [W-1:0] o); assign o = C.v; endmodule
module top(output logic [7:0] o); sub #(.W(8)) u(.o(o)); endmodule
