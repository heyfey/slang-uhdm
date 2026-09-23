// face-1 break: leaf localparam typed wider, sized init
package q2;
  localparam logic [7:0] L = 6'h2A;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {L, 6'h1}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
