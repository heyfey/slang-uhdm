// face-1 break: leaf param from ANOTHER package
package q1; parameter logic [5:0] L = 6'h2A; endpackage
package q2;
  
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {q1::L, 6'h1}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
