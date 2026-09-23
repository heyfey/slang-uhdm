// face-1 break: module-home pattern in a module that imports the package (not the package param)
package q2;
  typedef struct packed { logic [3:0] a; logic [7:0] v; } e_t;
  localparam logic [3:0] L = 4'h2;
endpackage
module top import q2::*; (output logic [7:0] o);
  localparam e_t M = '{a: 4'h1, v: {L, 4'h3}};
  assign o = M.v;
endmodule
